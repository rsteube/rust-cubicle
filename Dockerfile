FROM codercom/code-server

USER root

RUN apt-get update \
 && export DEBIAN_FRONTEND=noninteractive \
 && apt-get install -y expect \
                       unzip \
                       curl \
                       gcc \
                       libssl-dev \
                       musl-dev \
                       pkg-config
 
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y
ENV PATH /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/root/.cargo/bin/
ENV TARGET x86_64-unknown-linux-musl

RUN rustup default nightly
RUN rustup target add x86_64-unknown-linux-musl --toolchain=nightly
ENV HOST x86_64-unknown-linux-musl

RUN cargo install cargo-watch
RUN cargo install cargo-add
RUN rustup component add --toolchain stable rls rust-analysis rust-src

ADD vsix-add \
    ext \
    rls-build /usr/local/bin/

RUN ext install rust-lang.rust 0.5.3

ENV CARGO_TARGET_DIR=/root/target

ONBUILD RUN mkdir src && touch src/lib.rs && echo 'fn main() {}' > src/main.rs

ONBUILD ADD Cargo.lock Cargo.toml ./
ONBUILD RUN cargo build
ONBUILD RUN cargo build --tests
ONBUILD RUN rls-build

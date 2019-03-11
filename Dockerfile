FROM codercom/code-server

FROM ekidd/rust-musl-builder:nightly

COPY --from=0 /usr/local/bin/code-server /usr/local/bin/

USER root

RUN apt-get update \
 && apt-get install -y openssl \
                       net-tools \
                       expect

# upgrade libstdc++6 since code-server was build in ubuntu 18.10 and rust-musl-builder uses 16.04
RUN apt-get install -y software-properties-common \
 && add-apt-repository ppa:ubuntu-toolchain-r/test \
 && apt-get update \
 && apt-get install -y gcc-4.9 \
 && apt-get upgrade -y libstdc++6

USER rust

RUN cargo install cargo-watch
RUN cargo install cargo-add
RUN rustup component add rls rust-analysis rust-src

ADD vsix-add /usr/local/bin/
ADD ext /usr/local/bin/
RUN sudo apt-get install -y unzip

RUN ext install rust-lang.rust 0.5.3


ADD rls-build /usr/local/bin/

ONBUILD RUN mkdir src && touch src/lib.rs && echo 'fn main() {}' > src/main.rs

ONBUILD ADD Cargo.lock Cargo.toml ./

ONBUILD RUN cargo build
ONBUILD RUN cargo build --tests
ONBUILD RUN rls-build

ENTRYPOINT code-server





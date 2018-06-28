FROM i386/ubuntu:xenial as build

WORKDIR /rust_g

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    libssl-dev \
    ca-certificates \
    rustc \
    cargo \
    pkg-config \
    && git init \
    && git remote add origin https://github.com/tgstation/rust-g

#TODO: find a way to read these from .travis.yml or a common source eventually
ENV RUST_G_VERSION=0.3.0

RUN git fetch --depth 1 origin $RUST_G_VERSION \
    && git checkout FETCH_HEAD \
    && cargo build --release

FROM tgstation/byond:512.1427

EXPOSE 1337

WORKDIR /tgstation

COPY . .

RUN mkdir data && mkdir -p /root/.byond/bin

VOLUME [ "/tgstation/config", "/tgstation/data" ]

RUN DreamMaker -max_errors 0 tgstation.dme

COPY --from=build /rust_g/target/release/librust_g.so /root/.byond/bin/rust_g

ENTRYPOINT [ "DreamDaemon", "tgstation.dmb", "-port", "1337", "-trusted", "-close", "-verbose" ]

FROM tgstation/byond:512.1427 as base

FROM base as rustg

WORKDIR /rust_g

RUN apt-get update && apt-get install -y \
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

FROM base as dm_base

WORKDIR /tgstation

FROM dm_base as build

COPY . .

RUN DreamMaker -max_errors 0 tgstation.dme && tools/deploy.sh /deploy

FROM dm_base

EXPOSE 1337

RUN apt-get update && apt-get install -y \
    mariadb-client \
    libssl1.0.0 \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /root/.byond/bin

COPY --from=rustg /rust_g/target/release/librust_g.so /root/.byond/bin/rust_g
COPY --from=build /deploy ./

VOLUME [ "/tgstation/config", "/tgstation/data" ]

ENTRYPOINT [ "DreamDaemon", "tgstation.dmb", "-port", "1337", "-trusted", "-close", "-verbose" ]

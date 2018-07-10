FROM tgstation/byond:512.1427 as base

FROM base as rustg

WORKDIR /rust_g

RUN apt-get update && apt-get install -y \
    git \
    ca-certificates \
    libc6-dev

FROM build as rust_g

WORKDIR /rust_g

RUN apt-get install -y --no-install-recommends \
    libssl-dev \
    rustc \
    cargo \
    pkg-config

RUN git init \
    && git remote add origin https://github.com/tgstation/rust-g

#TODO: find a way to read these from .travis.yml or a common source eventually
ENV RUST_G_VERSION=0.3.0

RUN git fetch --depth 1 origin $RUST_G_VERSION \
    && git checkout FETCH_HEAD \
    && cargo build --release

FROM base as bsql

WORKDIR /bsql

RUN apt-get install -y --no-install-recommends software-properties-common \
    && add-apt-repository ppa:ubuntu-toolchain-r/test \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
    cmake \
    make \
    g++-7 \
    libstdc++6 \
    libmariadb-client-lgpl-dev

RUN git init \
    && git remote add origin https://github.com/tgstation/BSQL 

#TODO: find a way to read these from .travis.yml or a common source eventually
ENV BSQL_VERSION=v1.2.1.1

RUN git fetch --depth 1 origin $BSQL_VERSION \
    && git checkout FETCH_HEAD

WORKDIR /bsql/artifacts

ENV CC=gcc-7 CXX=g++-7

RUN ln -s /usr/include/mariadb /usr/include/mysql \
    && ln -s /usr/lib/i386-linux-gnu /root/MariaDB \
    && cmake .. \
    && make

FROM base as dm_base

WORKDIR /tgstation

FROM dm_base as build

COPY . .

RUN DreamMaker -max_errors 0 tgstation.dme

WORKDIR /deploy

RUN mkdir -p \
    .git/logs \
    _maps \
    config \
    icons/minimaps \
    sound/chatter \
    sound/voice/complionator \
    sound/instruments \
    strings \
    && cp /tgstation/tgstation.dmb /tgstation/tgstation.rsc ./ \
    && cp -r /tgstation/.git/logs/* .git/logs/ \
    && cp -r /tgstation/_maps/* _maps/ \
    && cp -r /tgstation/config/* config/ \
    && cp /tgstation/icons/default_title.dmi icons/ \
    && cp -r /tgstation/icons/minimaps/* icons/minimaps/ \
    && cp -r /tgstation/sound/chatter/* sound/chatter/ \
    && cp -r /tgstation/sound/voice/complionator/* sound/voice/complionator/ \
    && cp -r /tgstation/sound/instruments/* sound/instruments/ \
    && cp -r /tgstation/strings/* strings/

FROM dm_base

EXPOSE 1337

RUN apt-get update && apt-get install -y \
    mariadb-client \
    libssl1.0.0 \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /root/.byond/bin

COPY --from=rustg /rust_g/target/release/librust_g.so /root/.byond/bin/rust_g
COPY --from=bsql /bsql/artifacts/src/BSQL/libBSQL.so ./
COPY --from=build /deploy ./

#bsql fexists memes
RUN ln -s /tgstation/libBSQL.so /root/.byond/bin/libBSQL.so

VOLUME [ "/tgstation/config", "/tgstation/data" ]

ENTRYPOINT [ "DreamDaemon", "tgstation.dmb", "-port", "1337", "-trusted", "-close", "-verbose" ]

FROM i386/ubuntu:xenial as build

RUN apt-get update && apt-get install -y --no-install-recommends \
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

FROM build as bsql

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

FROM tgstation/byond:512.1427

EXPOSE 1337

WORKDIR /tgstation

#becuase we built BSQL using the test toolchain we need it here as well
RUN apt-get install -y --no-install-recommends software-properties-common \
    && add-apt-repository ppa:ubuntu-toolchain-r/test \
    && apt-get update \
    && apt-get install -y --no-install-recommends libstdc++6:i386 \
    && apt-get purge -y software-properties-common \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

COPY . .

RUN mkdir data && mkdir -p /root/.byond/bin && DreamMaker -max_errors 0 tgstation.dme

VOLUME [ "/tgstation/config", "/tgstation/data" ]

COPY --from=rust_g /rust_g/target/release/librust_g.so /root/.byond/bin/rust_g
COPY --from=bsql /bsql/artifacts/src/BSQL/libBSQL.so /tgstation/

#bsql fexists memes
RUN ln -s /tgstation/libBSQL.so /root/.byond/bin/libBSQL.so

ENTRYPOINT [ "DreamDaemon", "tgstation.dmb", "-port", "1337", "-trusted", "-close", "-verbose" ]

# base = ubuntu + full apt update
FROM ubuntu:xenial AS base

RUN dpkg --add-architecture i386 \
    && apt-get update \
    && apt-get upgrade -y \
    && apt-get dist-upgrade -y

# byond = base + byond installed globally
FROM base AS byond
WORKDIR /byond

RUN apt-get install -y --no-install-recommends \
        curl \
        unzip \
        make \
        libstdc++6:i386

COPY dependencies.sh .

RUN . ./dependencies.sh \
    && curl "http://www.byond.com/download/build/${BYOND_MAJOR}/${BYOND_MAJOR}.${BYOND_MINOR}_byond_linux.zip" -o byond.zip \
    && unzip byond.zip \
    && cd byond \
    && sed -i 's|install:|&\n\tmkdir -p $(MAN_DIR)/man6|' Makefile \
    && make install \
    && chmod 644 /usr/local/byond/man/man6/* \
    && apt-get purge -y --auto-remove curl unzip make \
    && cd .. \
    && rm -rf byond byond.zip /var/lib/apt/lists/*

# build = byond + tgstation compiled and deployed to /deploy
FROM byond AS build
WORKDIR /tgstation

COPY . .

RUN DreamMaker -max_errors 0 tgstation.dme \
    && tools/deploy.sh /deploy \
	&& rm /deploy/*.dll

# rust_g = base + rust_g compiled to /rust_g
FROM base as rust_g
WORKDIR /rust_g

RUN apt-get install -y --no-install-recommends \
        pkg-config:i386 \
        libssl-dev:i386 \
        curl \
        gcc-multilib \
    && curl https://sh.rustup.rs -sSf | sh -s -- -y \
    && ~/.cargo/bin/rustup target add i686-unknown-linux-gnu \
    && git init \
    && git remote add origin https://github.com/tgstation/rust-g

COPY dependencies.sh .

RUN . dependencies.sh \
    && git fetch --depth 1 origin \$RUST_G_VERSION \
    && git checkout FETCH_HEAD \
    && env PKG_CONFIG_ALLOW_CROSS=1 ~/.cargo/bin/cargo build --release --target i686-unknown-linux-gnu

# final = byond + runtime deps + rust_g + build
FROM byond
WORKDIR /tgstation

RUN apt-get install -y --no-install-recommends \
        libmariadb2 \
        mariadb-client \
        libssl1.0.0

COPY --from=build /deploy ./
COPY --from=rust_g /rust_g/target/release/librust_g.so ./librust_g.so

VOLUME [ "/tgstation/config", "/tgstation/data" ]
ENTRYPOINT [ "DreamDaemon", "tgstation.dmb", "-port", "1337", "-trusted", "-close", "-verbose" ]
EXPOSE 1337

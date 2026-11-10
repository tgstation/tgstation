# base = ubuntu + full apt update
FROM ubuntu:noble AS base
RUN dpkg --add-architecture i386 \
    && apt-get update \
    && apt-get upgrade -y \
    && apt-get dist-upgrade -y \
    && apt-get install -y --no-install-recommends \
        ca-certificates

# byond = base + byond installed globally
FROM base AS byond
WORKDIR /byond

RUN apt-get install -y --no-install-recommends \
        libcurl4t64 \
        libcurl4t64:i386 \
        curl \
        unzip \
        make \
        build-essential \
        python3 \
        python3-pip \
        python3-venv \
        libstdc++6:i386

COPY dependencies.sh .

RUN . ./dependencies.sh \
    && curl -H "User-Agent: tgstation/1.0 CI Script" "http://www.byond.com/download/build/${BYOND_MAJOR}/${BYOND_MAJOR}.${BYOND_MINOR}_byond_linux.zip" -o byond.zip \
    && unzip byond.zip \
    && cd byond \
    && sed -i 's|install:|&\n\tmkdir -p $(MAN_DIR)/man6|' Makefile \
    && make install \
    && chmod 644 /usr/local/byond/man/man6/* \
    && apt-get purge -y --auto-remove curl make \
    && cd .. \
    && rm -rf byond byond.zip

RUN command -v DreamMaker \
    && ls -l /usr/local/byond/bin \
    && file /usr/local/byond/bin/DreamMaker \
    && ldd /usr/local/byond/bin/DreamMaker || true

RUN /usr/local/byond/bin/DreamMaker 2>&1 || true

# build = byond + tgstation compiled and deployed to /deploy
FROM byond AS build
WORKDIR /tgstation

RUN apt-get install -y --no-install-recommends \
        curl

COPY . .

RUN . ./dependencies.sh \
    && mkdir -p /root/.byond/bin \
    && curl -fL \
        "https://github.com/${DREAMLUAU_REPO}/releases/download/${DREAMLUAU_VERSION}/libdreamluau.so" \
        -o /root/.byond/bin/libdreamluau.so \
    && chmod 755 /root/.byond/bin/libdreamluau.so

RUN export PATH="/usr/local/byond/bin:${PATH}" && env TG_BOOTSTRAP_NODE_LINUX=1 tools/build/build.sh \
    && tools/deploy.sh /deploy

# rust = base + rustc and i686 target
FROM base AS rust
RUN apt-get install -y --no-install-recommends \
        curl && \
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --profile minimal \
    && ~/.cargo/bin/rustup target add i686-unknown-linux-gnu

# rust_g = base + rust_g compiled to /rust_g
FROM rust AS rust_g
WORKDIR /rust_g

RUN apt-get install -y --no-install-recommends \
        pkg-config \
        libssl-dev:i386 \
        gcc-multilib \
        git \
    && git init \
    && git remote add origin https://github.com/tgstation/rust-g

COPY dependencies.sh .

RUN . ./dependencies.sh \
    && git fetch --depth 1 origin "${RUST_G_VERSION}" \
    && git checkout FETCH_HEAD \
    && env PKG_CONFIG_ALLOW_CROSS=1 ~/.cargo/bin/cargo build --release --target i686-unknown-linux-gnu

# final = byond + runtime deps + rust_g + build
FROM byond
WORKDIR /tgstation

RUN apt-get install -y --no-install-recommends \
        libssl3t64:i386 \
        zlib1g:i386

COPY --from=build /deploy ./
COPY --from=rust_g /rust_g/target/i686-unknown-linux-gnu/release/librust_g.so ./librust_g.so

VOLUME [ "/tgstation/config", "/tgstation/data" ]
ENTRYPOINT [ "DreamDaemon", "tgstation.dmb", "-port", "1337", "-webclient", "-trusted", "-close", "-verbose" ]
EXPOSE 1337

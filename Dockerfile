# base = ubuntu + full apt update
FROM ubuntu:22.04 AS base
ENV DEBIAN_FRONTEND=noninteractive
RUN dpkg --add-architecture i386 \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        # We need these for the Box86 repo setup later
        wget \
        gpg

# byond = base + byond installed globally
FROM base AS byond
WORKDIR /byond

RUN apt-get install -y --no-install-recommends \
        libcurl4 \
        curl \
        unzip \
        make \
        # Standard 32-bit libs for BYOND
        libstdc++6:i386 \
        libunwind8:i386

COPY dependencies.sh .

RUN . ./dependencies.sh \
    && curl -H "User-Agent: tgstation/1.0 CI Script" "http://www.byond.com/download/build/${BYOND_MAJOR}/${BYOND_MAJOR}.${BYOND_MINOR}_byond_linux.zip" -o byond.zip \
    && unzip byond.zip \
    && cd byond \
    && sed -i 's|install:|&\n\tmkdir -p $(MAN_DIR)/man6|' Makefile \
    && make install \
    && cd .. \
    && rm -rf byond byond.zip

# build = byond + tgstation compiled
FROM byond AS build
WORKDIR /tgstation
COPY . .
# Ensure we have node for tgui
RUN apt-get install -y --no-install-recommends nodejs npm
RUN env TG_BOOTSTRAP_NODE_LINUX=1 tools/build/build.sh \
    && tools/deploy.sh /deploy

# rust = base + rustc natively for ARM
FROM base AS rust
RUN apt-get install -y --no-install-recommends curl build-essential
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --profile minimal
# No need to add target; it defaults to aarch64 on your server!

# rust_g = native ARM build
FROM rust AS rust_g
WORKDIR /rust_g
# Use native ARM pkg-config and ssl
RUN apt-get install -y --no-install-recommends \
        pkg-config \
        libssl-dev \
        git
COPY dependencies.sh .
RUN . ./dependencies.sh \
    && git init \
    && git remote add origin https://github.com/tgstation/rust-g \
    && git fetch --depth 1 origin "${RUST_G_VERSION}" \
    && git checkout FETCH_HEAD \
    && /root/.cargo/bin/cargo build --release

# final stage
FROM byond
WORKDIR /tgstation

# Box86 Setup
RUN wget https://ryanfortner.github.io/box86-debs/box86.list -O /etc/apt/sources.list.d/box86.list \
    && wget -qO- https://ryanfortner.github.io/box86-debs/KEY.gpg | gpg --dearmor -o /etc/apt/trusted.gpg.d/box86.gpg \
    && apt-get update && apt-get install -y box86-generic zlib1g:i386

COPY --from=build /deploy ./
# Note the path change here: we built natively, so it's just in /target/release/
COPY --from=rust_g /rust_g/target/release/librust_g.so ./librust_g.so

VOLUME [ "/tgstation/config", "/tgstation/data" ]
# We use box86 to bridge the gap between ARM and the Intel DreamDaemon
ENTRYPOINT [ "box86", "DreamDaemon", "tgstation.dmb", "-port", "1337", "-trusted", "-close", "-verbose" ]
EXPOSE 1337

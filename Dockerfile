FROM golang:alpine AS build

RUN --mount=type=cache,target=/var/cache/apk \
    ln -s /var/cache/apk /etc/apk/cache && \
    apk add git build-base opus-dev autoconf libtool pkgconfig automake ccache

RUN git clone --branch 1.1.2 --depth 1 https://github.com/xiph/opus.git /opus
WORKDIR /opus

RUN ln -s ccache /usr/local/bin/gcc && ln -s ccache /usr/local/bin/g++ && ln -s ccache /usr/local/bin/cc && ln -s ccache /usr/local/bin/c++
ENV CCACHE_DIR=/ccache

RUN --mount=type=cache,target=/ccache \
    ./autogen.sh && ./configure && make

ARG PKG_CONFIG_PATH="/opus"

COPY . /dca
WORKDIR /dca

RUN --mount=type=cache,target=/go/pkg/mod \
    go mod download

RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    --mount=type=cache,target=/ccache \
    go build -trimpath -ldflags '-s -w' -o dca

RUN strip /dca/dca

FROM scratch

COPY --from=build /dca/dca /usr/bin/

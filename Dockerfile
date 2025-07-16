FROM golang:bookworm AS build

RUN apt update && apt install git build-essential libopus-dev autoconf libtool pkg-config -y

RUN git clone --branch 1.1.2 --depth 1 https://github.com/xiph/opus /opus
WORKDIR /opus
RUN ./autogen.sh
RUN ./configure
RUN make
ARG PKG_CONFIG_PATH="${PKG_CONFIG_PATH}:/opus"

COPY . /dca
WORKDIR /dca
RUN go mod download
RUN go build -trimpath -ldflags "-s -w" -o dca && chmod a+rx /dca/dca
RUN strip /dca/dca

FROM scratch

COPY --from=build /dca/dca /usr/bin/

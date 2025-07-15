FROM golang:bookworm AS build

RUN apt update && apt install git build-essential libopus-dev autoconf libtool pkg-config -y

RUN git clone https://github.com/xiph/opus /opus
WORKDIR /opus
RUN git checkout 1.1.2
RUN ./autogen.sh
RUN ./configure
RUN make
ARG PKG_CONFIG_PATH="${PKG_CONFIG_PATH}:/opus"

RUN git clone https://github.com/TheTipo01/dca /dca
WORKDIR /dca/cmd/dca
RUN go mod download
RUN go build -trimpath -ldflags "-s -w" -o dca
RUN strip /dca/cmd/dca/dca

FROM scratch

COPY --from=build /dca/cmd/dca/dca /usr/bin/

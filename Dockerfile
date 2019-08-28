FROM debian:8-slim as build

ENV MEGATOOLS_DOWNLOAD_URL https://megatools.megous.com/builds/megatools-1.9.91.tar.gz
ENV MEGATOOLS_DOWNLOAD_SHA256 31d0e55a25ba8420889a0ab6f43b04bdc4a919a2301c342b7baf1aab311f6841

RUN apt-get update
RUN apt-get install -y --no-install-recommends \
    wget ca-certificates build-essential libglib2.0-dev libssl-dev libcurl4-openssl-dev
RUN wget -O megatools.tar.gz "$MEGATOOLS_DOWNLOAD_URL"
RUN echo "$MEGATOOLS_DOWNLOAD_SHA256 *megatools.tar.gz" | sha256sum -c
RUN mkdir -p /usr/src/megatools /build
RUN tar -xvf megatools.tar.gz -C /usr/src/megatools --strip-components=1
WORKDIR /usr/src/megatools
RUN ./configure --prefix=/build
RUN make -j4
RUN make install
RUN ls -lhR /build

FROM debian:8-slim

RUN set -xe; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        libcurl3 ca-certificates libc6 libglib2.0-0 libssl1.0.0 glib-networking \
        ; \
    rm -rf /var/lib/apt/lists/*

COPY --from=build /build /usr/local/

RUN ldconfig -v && megals --version

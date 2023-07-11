FROM alpine:3.18.2
COPY  --from=lncm/berkeleydb:v4.8.30.NC  /opt  /opt
RUN export BDB_PREFIX="/opt"

RUN apk add --no-cache git make g++ autoconf automake libtool libevent-dev pkgconf boost-dev openssl-dev bash

RUN addgroup --gid 1000 maza
RUN adduser \
    --disabled-password \
    --gecos "" \
    --home /maza \
    --ingroup maza \
    --uid 1000 \
    maza

USER maza
RUN mkdir /maza/.maza
VOLUME /maza/.maza

RUN git clone https://github.com/MazaCoin/maza.git /maza/maza
WORKDIR /maza/maza
RUN git checkout tags/v0.16.3

RUN ./autogen.sh
RUN ./configure --without-gui  BDB_LIBS="-L${BDB_PREFIX}/lib -ldb_cxx-4.8" BDB_CFLAGS="-I${BDB_PREFIX}/include"
RUN make

COPY ./entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
EXPOSE 12835/tcp
EXPOSE 12832/tcp

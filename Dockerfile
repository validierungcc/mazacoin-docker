FROM ubuntu:18.04 AS builder
ENV DEBIAN_FRONTEND=noninteractive
ENV BDB_PREFIX="/usr/local"
ENV LD_LIBRARY_PATH="/usr/local/lib"

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    git make g++ wget autoconf automake libtool \
    libevent-dev pkg-config libboost-all-dev \
    libssl-dev bash ca-certificates bsdmainutils && \
    addgroup --gid 1000 maza && \
    adduser --disabled-password --gecos "" --home /maza --ingroup maza --uid 1000 maza && \
    mkdir -p /maza/.maza && \
    chown -R maza:maza /maza/.maza && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /maza
RUN wget http://download.oracle.com/berkeley-db/db-4.8.30.NC.tar.gz && \
    tar -xzvf db-4.8.30.NC.tar.gz && \
    cd db-4.8.30.NC/build_unix && \
    ../dist/configure --prefix=$BDB_PREFIX --enable-cxx && \
    make -j$(nproc) && \
    make install && \
    cd ../.. && \
    rm -rf db-4.8.30.NC db-4.8.30.NC.tar.gz

RUN git clone https://github.com/MazaCoin/maza.git /maza/maza && \
    cd /maza/maza && \
    git checkout tags/v0.16.3 && \
    ./autogen.sh && \
    ./configure --without-gui --with-bdb=$BDB_PREFIX && \
    make -j$(nproc)

RUN mkdir -p /output && \
    cp /usr/local/lib/libdb_cxx-4.8.so /output/ && \
    cp /maza/maza/src/mazad /output/

FROM ubuntu:18.04
ENV DEBIAN_FRONTEND=noninteractive
ENV LD_LIBRARY_PATH="/usr/local/lib"

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    libevent-dev libboost-all-dev libssl-dev ca-certificates && \
    rm -rf /var/lib/apt/lists/*

COPY --from=builder /output/libdb_cxx-4.8.so /usr/local/lib/
COPY --from=builder /output/mazad /usr/local/bin/

RUN addgroup --gid 1000 maza && \
    adduser --disabled-password --gecos "" --home /maza --ingroup maza --uid 1000 maza && \
    mkdir -p /maza/.maza && \
    chown -R maza:maza /maza/.maza
USER maza
VOLUME /maza/.maza

COPY ./entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 12835/tcp
EXPOSE 12832/tcp

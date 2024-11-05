FROM ubuntu:18.04
ENV DEBIAN_FRONTEND=noninteractive

ENV BDB_PREFIX="/usr/local"
ENV LD_LIBRARY_PATH="/usr/local/lib"
# Install required packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    git make g++ wget autoconf automake libtool \
    libevent-dev pkg-config sudo libboost-all-dev \
    libssl-dev bash ca-certificates bsdmainutils libdb-dev libdb++-dev && \
    rm -rf /var/lib/apt/lists/*

# Berechtigungen für /usr/local sicherstellen
RUN mkdir -p /usr/local/include && chmod -R 755 /usr/local

# Create user and group
RUN addgroup --gid 1000 maza && \
    adduser --disabled-password --gecos "" --home /maza --ingroup maza --uid 1000 maza

# Set up home directory for user
USER maza
RUN mkdir -p /maza/.maza
VOLUME /maza/.maza

# Download and build Berkeley DB 4.8
WORKDIR /maza

RUN wget http://download.oracle.com/berkeley-db/db-4.8.30.NC.tar.gz
RUN tar -xzvf db-4.8.30.NC.tar.gz
WORKDIR /maza/db-4.8.30.NC/build_unix
RUN ../dist/configure --prefix=$BDB_PREFIX --enable-cxx
RUN make
USER root
RUN make install && \
    cd ../.. && \
    rm -rf db-4.8.30.NC db-4.8.30.NC.tar.gz
USER maza
# Clone and set up Maza repository
RUN git clone https://github.com/MazaCoin/maza.git /maza/maza
WORKDIR /maza/maza
RUN git checkout tags/v0.16.3

# Build the project
RUN ./autogen.sh
RUN ./configure --without-gui -with-bdb=$BDB_PREFIX


RUN make

# Copy entrypoint script
COPY ./entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]

# Expose ports
EXPOSE 12835/tcp
EXPOSE 12832/tcp
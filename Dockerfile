FROM ubuntu:18.04
ENV DEBIAN_FRONTEND=noninteractive

ENV BDB_PREFIX="/opt"
# Install required packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    git make g++ autoconf automake libtool \
    libevent-dev pkg-config libboost-all-dev \
    libssl-dev bash ca-certificates bsdmainutils libdb-dev libdb++-dev && \
    rm -rf /var/lib/apt/lists/*

# Copy Berkeley DB from the specified source
COPY --from=lncm/berkeleydb:v4.8.30.NC /opt /opt

# Create user and group
RUN addgroup --gid 1000 maza && \
    adduser --disabled-password --gecos "" --home /maza --ingroup maza --uid 1000 maza

# Set up home directory for user
USER maza
RUN mkdir -p /maza/.maza
VOLUME /maza/.maza

# Clone and set up Maza repository
RUN git clone https://github.com/MazaCoin/maza.git /maza/maza
WORKDIR /maza/maza
RUN git checkout tags/v0.16.3

# Build the project
RUN ./autogen.sh
RUN ./configure --without-gui --with-incompatible-bdb


RUN make

# Copy entrypoint script
COPY ./entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]

# Expose ports
EXPOSE 12835/tcp
EXPOSE 12832/tcp
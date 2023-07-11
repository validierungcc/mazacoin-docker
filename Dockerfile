FROM alpine:3.18.2
RUN apk add --no-cache git make g++ bash

RUN addgroup --gid 1000 maza
RUN adduser \
    --disabled-password \
    --gecos "" \
    --home /maza \
    --ingroup maza \
    --uid 1000 \
    emark

USER maza
RUN mkdir /maza/.maza
VOLUME /maza/.maza

RUN git clone https://github.com/MazaCoin/maza.git /maza/maza
WORKDIR /maza/maza
RUN git checkout tags/v0.16.3

WORKDIR /maza/maza/src
RUN make -f makefile.unix
COPY ./entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
EXPOSE 12835/tcp
EXPOSE 12832/tcp

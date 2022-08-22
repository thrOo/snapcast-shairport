FROM alpine:edge as builder

WORKDIR /usr/src/app

RUN apk -U add \
	git \
	build-base \
	autoconf \
    automake \
    libtool \
    dbus \
    su-exec \
    alsa-lib-dev \
    libdaemon-dev \
    popt-dev \
    mbedtls-dev \
    soxr-dev \
    avahi-dev \
    libconfig-dev \
    libsndfile-dev \
    xmltoman 
	


RUN git clone https://github.com/badaix/snapcast.git 
RUN git clone https://github.com/mikebrady/shairport-sync.git 
WORKDIR /usr/src/app/shairport-sync/

RUN autoreconf -fi
RUN ./configure \
        --sysconfdir=/etc \
        --with-alsa \
        --with-stdout \
        --with-avahi \
        --with-ssl=mbedtls \
        --with-soxr \
        --with-metadata 
RUN make
RUN make install

FROM alpine:edge
WORKDIR /usr/src/app

RUN mkdir tmp
RUN touch tmp/mopidy.fifo

COPY snapserver.conf snapserver.conf
COPY start.sh start.sh

COPY --from=builder /usr/src/app/snapcast/server/etc/snapweb /usr/src/app/snapweb

COPY --from=builder /etc/shairport-sync* /etc/
COPY --from=builder /usr/local/bin/shairport-sync /usr/local/bin/shairport-sync

RUN apk -U add \
        snapcast-server\
        bash \
        dbus \
        alsa-lib \
        popt \
        glib \
        mbedtls \
        soxr \
        avahi \
        libconfig \
        libsndfile \
        su-exec \
        libgcc \
        libgc++

RUN rm -rf  /lib/apk/db/*i /var/cache/apk/* shairport-sync

CMD ["bash","start.sh"]


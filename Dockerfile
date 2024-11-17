FROM alpine:3.17 AS builder

WORKDIR /usr/src/app

RUN apk -U add \
    alsa-lib-dev \
    autoconf \
    automake \
    avahi-dev \
    build-base \
    dbus \
    ffmpeg-dev \
    git \
    libconfig-dev \
    libgcrypt-dev \
    libplist-dev \
    libressl-dev \
    libsndfile-dev \
    libsodium-dev \
    libtool \
    # libdaemon-dev \
    # su-exec \
    mosquitto-dev \
    popt-dev \
    pulseaudio-dev \
    # mbedtls-dev \
    soxr-dev \
    xxd
    # xmltoman 
	
##### NQPTP #####
WORKDIR /
RUN git clone https://github.com/mikebrady/nqptp
WORKDIR /nqptp
RUN git checkout development
RUN autoreconf -i
RUN ./configure
RUN make
WORKDIR /usr/src/app
##### NQPTP END #####

RUN git clone https://github.com/badaix/snapcast.git 
RUN git clone https://github.com/mikebrady/shairport-sync.git 
WORKDIR /usr/src/app/shairport-sync/

RUN autoreconf -fi
RUN ./configure \
        --sysconfdir=/etc \
        --with-alsa \
        --with-stdout \
        --with-avahi \
        --with-ssl=openssl \
        --with-soxr \
        --with-metadata \
	--with-airplay-2  
RUN make
RUN make install

FROM crazymax/alpine-s6:3.17-3.1.1.2

ENV S6_CMD_WAIT_FOR_SERVICES=1
ENV S6_CMD_WAIT_FOR_SERVICES_MAXTIME=0

COPY ./etc/s6-overlay/s6-rc.d /etc/s6-overlay/s6-rc.d

WORKDIR /usr/src/app

RUN mkdir tmp
RUN touch tmp/mopidy.fifo

COPY snapserver.conf snapserver.conf
COPY start.sh start.sh


COPY --from=builder /usr/src/app/snapcast/server/etc/snapweb /usr/src/app/snapweb

COPY --from=builder /nqptp/nqptp /usr/local/bin/nqptp
COPY --from=builder /usr/local/lib/libalac.* /usr/local/lib/
COPY --from=builder /etc/shairport-sync* /etc/
COPY --from=builder /usr/local/bin/shairport-sync /usr/local/bin/shairport-sync

RUN apk -U add \
        snapcast-server\
        bash \
        dbus \
	alsa-lib \
        popt \
        glib \
        # mbedtls \
        ffmpeg \
	soxr \
        avahi \
	libgcrypt \
        libplist \
        libpulse \
        libressl3.6-libcrypto \
        libsndfile \
        libsodium \
        libuuid \
        libconfig \
        libsndfile \
        # su-exec \
        libgcc \
        libgc++

RUN rm -rf  /lib/apk/db/*i /var/cache/apk/* shairport-sync

RUN chmod +x /etc/s6-overlay/s6-rc.d/01-startup/script.sh
RUN chmod +x /etc/s6-overlay/s6-rc.d/02-dbus/data/check
RUN chmod +x /etc/s6-overlay/s6-rc.d/03-avahi/data/check

RUN chmod +x start.sh

ENTRYPOINT ["/init","./start.sh"]


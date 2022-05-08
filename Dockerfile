FROM alpine:edge

WORKDIR /usr/src/app

COPY snapserver.conf snapserver.conf
COPY start.sh start.sh

RUN apk -U add \
	snapcast-server \
	git \
	build-base \
	bash \
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
        xmltoman \
	libgcc \
        libgc++
	

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

RUN apk --purge del \
	git \
	build-base \
	autoconf \
	automake \
	libtool \
	alsa-lib-dev \
        libdaemon-dev \
        popt-dev \
        mbedtls-dev \
        soxr-dev \
        avahi-dev \
        libconfig-dev \
        libsndfile-dev

RUN apk -U add \
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

RUN rm -rf  /lib/apk/db/*i /var/cache/apk/*


WORKDIR /usr/src/app

CMD ["bash","start.sh"]


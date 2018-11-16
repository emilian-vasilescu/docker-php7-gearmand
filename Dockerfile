FROM debian:jessie

MAINTAINER Alexandru Voinescu "voinescu.alex@gmail.com"

# Setup environment
ENV DEBIAN_FRONTEND noninteractive

USER root

RUN apt-get update -y && apt-get install -y --no-install-recommends apt-utils

RUN apt-get install wget apache2 mysql-client -y

RUN echo "deb http://packages.dotdeb.org jessie all" >> /etc/apt/sources.list
RUN echo "deb-src http://packages.dotdeb.org jessie all" >> etc/apt/sources.list

RUN wget https://www.dotdeb.org/dotdeb.gpg
RUN apt-key add dotdeb.gpg -y

RUN apt-get update -y

RUN apt-get install php7.0 php7.0-dev php7.0-common php-pear php7.0-opcache php7.0-mysql php7.0-zip php7.0-curl -y

RUN apt-get install libapache2-mod-php7.0 -y

RUN pecl install timecop-beta

RUN echo "extension=timecop.so" >> /etc/php/7.0/cli/php.ini

RUN apt-get update && apt-get install -y supervisor
RUN mkdir -p /var/log/supervisor
COPY supervisor.conf /etc/supervisor/conf.d/supervisor.conf
COPY init.sh /init.sh

RUN apt-get install software-properties-common -y

RUN apt update --force-yes
RUN	apt install -y \
	curl \
	libgearman-dev \
	unzip \
	re2c \
	gearman-job-server

WORKDIR /usr/local/src

ENV GEARMAN_VERSION="1.1.18"
ENV GEARMAN_URL="https://github.com/gearman/gearmand/releases/download/$GEARMAN_VERSION/gearmand-$GEARMAN_VERSION.tar.gz" \
    BUILD_DEPENDENCIES="\
        autoconf \
        ca-certificates \
		dpkg-dev \
		file \
		g++ \
		gcc \
		libc-dev \
		make \
		pkg-config \
        \
        wget\
        " \
    RUN_DEPENDENCIES="\
        libboost-all-dev \
        libevent-dev \
        bison \
        flex \
        libtool \
        uuid-dev \
        gperf \
        "

USER root

RUN apt-get update \
    && apt-get install -y --no-install-recommends $BUILD_DEPENDENCIES $RUN_DEPENDENCIES \
    \
    && wget -q $GEARMAN_URL -O gearmand.tar.gz \
    && mkdir /usr/local/src/gearmand \
    && tar zxf gearmand.tar.gz -C /usr/local/src/gearmand --strip-components=1 \
    && ( \
        cd /usr/local/src/gearmand \
        && ./configure --with-lib-dir=/usr/lib/x86_64-linux-gnu \
        && make \
        && make install \
    ) \
    && rm gearmand.tar.gz \
    && mkdir -p /var/log/gearman \
&& chown gearman:gearman /var/log/gearman

RUN cd /tmp/ \
	&& wget https://github.com/wcgallego/pecl-gearman/archive/master.zip \
	&& unzip master.zip \
	&& cd pecl-gearman-master \
	&& phpize \
	&& ./configure \
	&& make \
	&& make install \
	&& make test \
	&& echo "extension=gearman.so" | tee /etc/php/7.0/mods-available/gearman.ini
RUN phpenmod -v ALL -s ALL gearman

EXPOSE 4730

RUN gearmand --version

CMD ["/bin/bash", "init.sh"]

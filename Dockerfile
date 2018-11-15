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
RUN	apt install -y curl \
	gearman-job-server \ 
	libgearman-dev \
	unzip \
	re2c

RUN cd /tmp/ \
	&& wget https://github.com/wcgallego/pecl-gearman/archive/master.zip \
	&& unzip master.zip \
	&& cd pecl-gearman-master \
	&& phpize \
	&& ./configure \
	&& make \
	&& make install \
	&& echo "extension=gearman.so" | tee /etc/php/7.0/mods-available/gearman.ini
RUN phpenmod -v ALL -s ALL gearman 

CMD ["/bin/bash", "init.sh"]

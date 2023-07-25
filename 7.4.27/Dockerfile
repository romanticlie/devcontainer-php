FROM php:7.4.27-fpm-alpine


ARG TZ=Asia/Shanghai
ARG PHP_VERSION=php:7.4.27-fpm-alpine
ARG CONTAINER_PACKAGE_URL=mirrors.ustc.edu.cn
ARG PHP_EXTENSIONS=gd,bcmath,mysqli,pdo_mysql,gettext,soap,xsl,sysvsem,sysvshm,xmlrpc,redis,mongodb,swoole,bz2,calendar,opcache,pcntl,sockets,xdebug,amqp,zip,apcu

RUN if [ $CONTAINER_PACKAGE_URL ] ; then sed -i "s/dl-cdn.alpinelinux.org/${CONTAINER_PACKAGE_URL}/g" /etc/apk/repositories ; fi

COPY ./extensions /tmp/extensions
WORKDIR /tmp/extensions
RUN chmod +x install.sh \
    && sh install.sh

ADD ./extensions/install-php-extensions  /usr/local/bin/    

RUN chmod uga+x /usr/local/bin/install-php-extensions

# sync timezone
RUN apk --no-cache add tzdata \
    && cp "/usr/share/zoneinfo/$TZ" /etc/localtime \
    && echo "$TZ" > /etc/timezone 


# Fix: https://github.com/docker-library/php/issues/1121
RUN apk add --no-cache --repository http://${CONTAINER_PACKAGE_URL}/alpine/v3.13/community/ gnu-libiconv=1.15-r3
ENV LD_PRELOAD /usr/lib/preloadable_libiconv.so php


# Install composer and change it's cache home
RUN chmod +x install-composer.sh \
    && sh install-composer.sh \
    && rm -rf /tmp/extensions
ENV COMPOSER_HOME=/tmp/composer


EXPOSE 9000

# php image's www-data user uid & gid are 82, change them to 1000 (primary user)
RUN apk --no-cache add shadow && usermod -u 1000 www-data && groupmod -g 1000 www-data && apk add git && mkdir /var/log/php

# copy php config
COPY ./php.ini /usr/local/etc/php/php.ini
COPY ./php-fpm.conf /usr/local/etc/php-fpm.d/www.conf


WORKDIR /www
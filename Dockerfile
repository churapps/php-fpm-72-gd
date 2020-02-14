FROM php:7.2-fpm-alpine

# php ext
RUN apk update && \
    apk --no-cache upgrade && \
    apk --no-cache add libmcrypt-dev mysql-client git openssl-dev freetype libpng libjpeg-turbo freetype-dev libpng-dev libjpeg-turbo-dev

# php ext redis
RUN docker-php-source extract && \
    git clone -b 4.1.1 --depth 1 https://github.com/phpredis/phpredis.git /usr/src/php/ext/redis && \
    docker-php-ext-install redis

RUN docker-php-ext-configure gd \
    --with-gd \
    --with-freetype-dir=/usr/include/ \
    --with-png-dir=/usr/include/ \
    --with-jpeg-dir=/usr/include/ && \
    NPROC=$(grep -c ^processor /proc/cpuinfo 2>/dev/null || 1) && \
    docker-php-ext-install -j${NPROC} gd && \
    apk del --no-cache freetype-dev libpng-dev libjpeg-turbo-dev

RUN docker-php-ext-install pdo_mysql json mbstring

RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer
RUN composer config -g repos.packagist composer https://packagist.jp
RUN composer global require hirak/prestissimo

## detail config
# COPY ./config/www.conf /usr/local/etc/php-fpm.d/www.conf


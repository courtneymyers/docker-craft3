FROM php:7.2-fpm-alpine3.7

LABEL maintainer="Courtney Myers <courtney.myers@erg.com>" \
      description="Minimal PHP 7.2 and Apache 2 for Craft CMS" \
      vesion="1.0"

RUN apk add --no-cache \
    # install apache
    apache2 \
    # install required php extensions for craft
    php7-apache2 \
    php7-mbstring \
    # install expect for passing arguments to craft setup script's prompts
    expect \
    # install dependencies of php extension zip
    zlib-dev; \
    # create missing apache2 run directory
    mkdir -p /run/apache2; \
    # install required php extensions for composer and craft
    docker-php-ext-install zip; \
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"; \
    php composer-setup.php --install-dir=/usr/local/bin --filename=composer; \
    php -r "unlink('composer-setup.php');"

# install imagemagick php extension for craft
RUN apk add --no-cache --virtual .phpize-deps $PHPIZE_DEPS imagemagick-dev libtool; \
    export CFLAGS="$PHP_CFLAGS" CPPFLAGS="$PHP_CPPFLAGS" LDFLAGS="$PHP_LDFLAGS"; \
    pecl install imagick-3.4.3; \
    docker-php-ext-enable imagick; \
    apk add --no-cache --virtual .imagick-runtime-deps imagemagick; \
    apk del .phpize-deps;

# install craft
RUN composer create-project --stability RC craftcms/craft .

# configure apache virtual hosts, php settings, and server root permissions
COPY config/vhosts.conf /etc/apache2/conf.d/
COPY config/php.ini /usr/local/etc/php
RUN chown -R apache:apache /var/www

# setup craft
COPY config/db-setup.exp tmp/
# RUN expect tmp/db-setup.exp; rm -rf tmp/

EXPOSE 80

# start apache in foreground
CMD /usr/sbin/httpd -D FOREGROUND

FROM alpine:3.7

LABEL maintainer="Courtney Myers <courtney.myers@erg.com>" \
      description="Minimal PHP 7.2 and Apache 2 for Craft CMS" \
      vesion="1.0"

# install apache, php, php extensions for craft, and other utilities
RUN apk add --no-cache \
    apache2 \
    php7 \
    php7-apache2 \
    php7-phar \
    php7-zlib \
    php7-ctype \
    php7-session \
    php7-fileinfo \
    # required php extensions for craft
    php7-pdo \
    php7-pdo_mysql \
    php7-gd \
    php7-openssl \
    php7-mbstring \
    php7-json \
    php7-curl \
    php7-zip \
    # optional extensions for craft
    php7-iconv \
    php7-intl \
    php7-dom \
    # expect for passing arguments to craft setup script's prompts
    expect;

# install composer, craft, and configure apache
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"; \
    php composer-setup.php; \
    rm composer-setup.php; \
    mv composer.phar /usr/bin/composer; \
    # install craft
    composer create-project --stability RC craftcms/craft /srv/www; \
    # create missing apache2 run directory
    mkdir -p /run/apache2; \
    # set server root permissions
    chown -R apache:apache /srv/www;

# ########################## run craft server check ############################
# RUN php /srv/www/vendor/craftcms/server-check/server/checkit.php
# ##############################################################################

# copy over config files
COPY config/ tmp/

# configure virtual hosts, php settings, and run craft setup script
RUN mv tmp/vhosts.conf /etc/apache2/conf.d/; \
    mv tmp/php.ini /etc/php7/conf.d;
    # expect tmp/db-setup.exp; \
    # rm -rf tmp/;

EXPOSE 80

# start apache in foreground
CMD /usr/sbin/httpd -D FOREGROUND

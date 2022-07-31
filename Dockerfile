FROM alpine:3.16

LABEL org.opencontainers.image.source https://github.com/premoweb/alpine-nginx-php8

RUN apk update && apk add --no-cache \
  php81 \
  php81-bcmath \
  php81-bz2 \
  php81-calendar \
  php81-cgi \
  php81-common \
  php81-ctype \
  php81-curl \
  php81-dba \
  php81-dbg \
  php81-dev \
  php81-doc \
  php81-dom \
  php81-embed \
  php81-enchant \
  php81-exif \
  php81-ffi \
  php81-fileinfo \
  php81-fpm \
  php81-ftp \
  php81-gd \
  php81-gettext \
  php81-gmp \
  php81-iconv \
  php81-imap \
  php81-intl \
  php81-ldap \
  php81-mbstring \
  php81-mysqli \
  php81-mysqlnd \
  php81-odbc \
  php81-opcache \
  php81-openssl \
  php81-pcntl \
  php81-pdo \
  php81-pdo_dblib \
  php81-pdo_mysql \
  php81-pdo_odbc \
  php81-pdo_pgsql \
  php81-pdo_sqlite \
  php81-pear \
  php81-pgsql \
  php81-phar \
  php81-phpdbg \
  php81-posix \
  php81-pspell \
  php81-session \
  php81-shmop \
  php81-simplexml \
  php81-snmp \
  php81-soap \
  php81-sockets \
  php81-sodium \
  php81-sqlite3 \
  php81-sysvmsg \
  php81-sysvsem \
  php81-sysvshm \
  php81-tidy \
  php81-tokenizer \
  php81-xml \
  php81-xmlreader \
  php81-xmlwriter \
  php81-xsl \
  php81-zip \
  nginx supervisor curl tzdata htop mysql-client dcron


# Configure nginx
COPY config/nginx.conf /etc/nginx/nginx.conf

# Configure PHP-FPM
COPY config/fpm-pool.conf /etc/php81/php-fpm.d/www.conf
COPY config/php.ini /etc/php81/conf.d/custom.ini

# Configure supervisord
COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Setup document root
RUN mkdir -p /var/www/html

RUN chown -R nobody.nobody /var/www/html && \
  chown -R nobody.nobody /run && \
  chown -R nobody.nobody /var/lib/nginx && \
  chown -R nobody.nobody /var/log/nginx

# Switch to use a non-root user from here on
USER nobody

# Add application
WORKDIR /var/www/html
COPY --chown=nobody backend/ /var/www/html/

# Expose the port nginx is reachable on
EXPOSE 80

# Let supervisord start nginx & php-fpm
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

# Configure a healthcheck to validate that everything is up&running
HEALTHCHECK --timeout=10s CMD curl --silent --fail http://127.0.0.1:80/fpm-ping
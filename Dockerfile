FROM alpine:3.15.5

LABEL org.opencontainers.image.source https://github.com/premoweb/alpine-nginx-php8

RUN apk update && apk add --no-cache \
  curl \
  nginx \
  php8 \
  php8-bcmath \
  php8-bz2 \
  php8-calendar \
  php8-cgi \
  php8-common \
  php8-ctype \
  php8-curl \
  php8-dba \
  php8-dbg \
  php8-dev \
  php8-doc \
  php8-dom \
  php8-embed \
  php8-enchant \
  php8-exif \
  php8-ffi \
  php8-fileinfo \
  php8-fpm \
  php8-ftp \
  php8-gd \
  php8-gettext \
  php8-gmp \
  php8-iconv \
  php8-imap \
  php8-intl \
  php8-ldap \
  php8-mbstring \
  php8-mysqli \
  php8-mysqlnd \
  php8-odbc \
  php8-opcache \
  php8-openssl \
  php8-pcntl \
  php8-pdo \
  php8-pdo_dblib \
  php8-pdo_mysql \
  php8-pdo_odbc \
  php8-pdo_pgsql \
  php8-pdo_sqlite \
  php8-pear \
  php8-pgsql \
  php8-phar \
  php8-phpdbg \
  php8-posix \
  php8-pspell \
  php8-session \
  php8-shmop \
  php8-simplexml \
  php8-snmp \
  php8-soap \
  php8-sockets \
  php8-sodium \
  php8-sqlite3 \
  php8-sysvmsg \
  php8-sysvsem \
  php8-sysvshm \
  php8-tidy \
  php8-tokenizer \
  php8-xml \
  php8-xmlreader \
  php8-xmlwriter \
  php8-xsl \
  php8-zip \
  nginx supervisor curl tzdata htop mysql-client dcron

# Configure nginx
COPY config/nginx.conf /etc/nginx/nginx.conf

# Configure PHP-FPM
COPY config/fpm-pool.conf /etc/php8/php-fpm.d/www.conf
COPY config/php.ini /etc/php8/conf.d/custom.ini

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
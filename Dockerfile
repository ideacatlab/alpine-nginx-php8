FROM alpine:3.18.2

LABEL org.opencontainers.image.source https://github.com/ideacatlab/alpine-nginx-php8

RUN apk update && apk add --no-cache \
  php82 \
  php82-bcmath \
  php82-bz2 \
  php82-calendar \
  php82-cgi \
  php82-common \
  php82-ctype \
  php82-curl \
  php82-dba \
  php82-dbg \
  php82-dev \
  php82-doc \
  php82-dom \
  php82-embed \
  php82-enchant \
  php82-exif \
  php82-ffi \
  php82-fileinfo \
  php82-fpm \
  php82-ftp \
  php82-gd \
  php82-gettext \
  php82-gmp \
  php82-iconv \
  php82-imap \
  php82-intl \
  php82-ldap \
  php82-mbstring \
  php82-mysqli \
  php82-mysqlnd \
  php82-odbc \
  php82-opcache \
  php82-openssl \
  php82-pcntl \
  php82-pdo \
  php82-pdo_dblib \
  php82-pdo_mysql \
  php82-pdo_odbc \
  php82-pdo_pgsql \
  php82-pdo_sqlite \
  php82-pear \
  php82-pgsql \
  php82-phar \
  php82-phpdbg \
  php82-posix \
  php82-pspell \
  php82-session \
  php82-shmop \
  php82-simplexml \
  php82-snmp \
  php82-soap \
  php82-sockets \
  php82-sodium \
  php82-sqlite3 \
  php82-sysvmsg \
  php82-sysvsem \
  php82-sysvshm \
  php82-tidy \
  php82-tokenizer \
  php82-xml \
  php82-xmlreader \
  php82-xmlwriter \
  php82-xsl \
  php82-zip \
  nginx supervisor curl tzdata composer htop mysql-client

# Configure nginx
COPY config/nginx.conf /etc/nginx/nginx.conf

# Configure PHP-FPM
COPY config/fpm-pool.conf /etc/php82/php-fpm.d/www.conf
COPY config/php.ini /etc/php82/conf.d/custom.ini

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

# Configure a healthcheck to validate that everything is up & running
HEALTHCHECK --timeout=10s CMD curl --silent --fail http://127.0.0.1:80/fpm-ping

# Let supervisord start nginx & php-fpm
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

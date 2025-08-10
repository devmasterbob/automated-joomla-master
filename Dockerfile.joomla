FROM php:8.3-apache

# Install system dependencies
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
    ghostscript \
    zstd \
    gosu \
    default-mysql-client \
    ; \
    rm -rf /var/lib/apt/lists/*

# Install PHP extensions required by Joomla
RUN set -ex; \
    savedAptMark="$(apt-mark showmanual)"; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
    libbz2-dev \
    libgmp-dev \
    libjpeg-dev \
    libldap2-dev \
    libmcrypt-dev \
    libmemcached-dev \
    libpng-dev \
    libpq-dev \
    libzip-dev \
    ; \
    docker-php-ext-configure gd --with-jpeg; \
    docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu; \
    docker-php-ext-install -j "$(nproc)" \
    bz2 \
    gd \
    gmp \
    ldap \
    mysqli \
    pdo_mysql \
    pdo_pgsql \
    pgsql \
    zip \
    ; \
    apt-mark auto '.*' > /dev/null; \
    apt-mark manual $savedAptMark; \
    ldd "$(php -r 'echo ini_get("extension_dir");')"/*.so \
    | awk '/=>/ { print $3 }' \
    | sort -u \
    | xargs -r dpkg-query -S \
    | cut -d: -f1 \
    | sort -u \
    | xargs -rt apt-mark manual; \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
    rm -rf /var/lib/apt/lists/*

# Configure PHP
RUN set -eux; \
    docker-php-ext-enable opcache; \
    { \
    echo 'opcache.memory_consumption=128'; \
    echo 'opcache.interned_strings_buffer=8'; \
    echo 'opcache.max_accelerated_files=4000'; \
    echo 'opcache.revalidate_freq=2'; \
    echo 'opcache.fast_shutdown=1'; \
    } > /usr/local/etc/php/conf.d/opcache-recommended.ini

# Enable Apache modules
RUN set -eux; \
    a2enmod rewrite expires; \
    a2enmod remoteip; \
    { \
    echo 'RemoteIPHeader X-Forwarded-For'; \
    echo 'RemoteIPInternalProxy 10.0.0.0/8'; \
    echo 'RemoteIPInternalProxy 172.16.0.0/12'; \
    echo 'RemoteIPInternalProxy 192.168.0.0/16'; \
    echo 'RemoteIPInternalProxy 169.254.0.0/16'; \
    echo 'RemoteIPInternalProxy 127.0.0.0/8'; \
    } > /etc/apache2/conf-available/remoteip.conf; \
    a2enconf remoteip

# Download and extract Joomla
RUN set -ex; \
    curl -o joomla.tar.zst -SL https://github.com/joomla/joomla-cms/releases/download/6.0.0-alpha3/Joomla_6.0.0-alpha3-Alpha-Full_Package.tar.zst; \
    mkdir -p /usr/src/joomla; \
    tar --extract --file joomla.tar.zst --directory /usr/src/joomla --strip-components=0 --no-same-owner --no-same-permissions; \
    rm joomla.tar.zst; \
    chown -R www-data:www-data /usr/src/joomla; \
    chmod -R 755 /usr/src/joomla

# Copy our scripts
COPY docker-entrypoint.sh /entrypoint.sh
COPY makedb.php /makedb.php
RUN chmod +x /entrypoint.sh

# Fix Apache logs permissions
RUN mkdir -p /var/log/apache2 && \
    chown -R www-data:www-data /var/log/apache2

VOLUME /var/www/html

ENTRYPOINT ["/entrypoint.sh"]
CMD ["apache2-foreground"]

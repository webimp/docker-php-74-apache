FROM php:7.4-apache

# Use Cloudflare DNS.
RUN echo "nameserver 1.1.1.1" | tee /etc/resolv.conf > /dev/null

# Install dependencies
RUN buildDeps=" \
        default-libmysqlclient-dev \
        libbz2-dev \
        libmemcached-dev \
        libsasl2-dev \
    " \
    runtimeDeps=" \
        apt-utils \
        curl \
        git \
        unzip \
        libc-client-dev \
        libfreetype6-dev \
        libgeoip-dev \
        libgmp-dev \
        libicu-dev \
        libjpeg-dev \
        libjpeg62-turbo-dev \
        libkrb5-dev \
        libldap2-dev \
        libmagickwand-dev \
        libmagickcore-dev \
        libmemcachedutil2 \
        libpng-dev \
        libpq-dev \
        zlib1g-dev \
        libpspell-dev \
        librecode0 \
        librecode-dev \
        libssh2-1 \
        libssh2-1-dev \
        libtidy-dev \
        libxml2-dev \
        libxslt1-dev \
        libyaml-dev \
        libzip-dev \
        openssh-client \
        rsync \
        sendmail-bin \
        sendmail \
        wget \
    " \
    phpExtensions=" \
        bcmath \
        bz2 \
        calendar \
        exif \
        gd \
        gettext \
        gmp \
        iconv \
        imap \
        intl \
        ldap \
        mbstring \
        mysqli \
        opcache \
        pcntl \
        pdo_mysql \
        pdo_pgsql \
        pgsql \
        pspell \
        recode \
        shmop \
        soap \
        sockets \
        sysvmsg \
        sysvsem \
        sysvshm \
        tidy \
        xmlrpc \
        xsl \
        zip \
    " \
    && apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y $buildDeps $runtimeDeps \
    && docker-php-ext-install $phpExtensions \
    && apt-get purge -y --auto-remove $buildDeps \
    && rm -r /var/lib/apt/lists/* \
    && a2enmod rewrite

# Configure libraries.
RUN docker-php-ext-configure \
  gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/
RUN docker-php-ext-configure \
  imap --with-kerberos --with-imap-ssl
RUN docker-php-ext-configure \
  ldap --with-libdir=lib/x86_64-linux-gnu
RUN docker-php-ext-configure \
  opcache --enable-opcache
RUN docker-php-ext-configure \
  zip --with-libzip

# Enable PHP extensions.
RUN phpExtensions=" \
        bcmath \
        bz2 \
        calendar \
        exif \
        gd \
        geoip \
        gettext \
        gmp \
        igbinary \
        imagick \
        imap \
        intl \
        ldap \
        mailparse \
        memcached.so \
        msgpack \
        mysqli \
        oauth \
        opcache \
        pdo_mysql \
        pcntl \
        propro \
        pspell \
        raphf \
        recode \
        redis.so \
        shmop \
        soap \
        sockets \
        sodium \
        ssh2 \
        sysvmsg \
        sysvsem \
        sysvshm \
        tidy \
        xdebug \
        xmlrpc \
        xsl \
        yaml \
        zip \
    " \
    && docker-php-ext-enable $phpExtensions

# Install pecl dependencies.
RUN pecl install -o -f \
  geoip-1.1.1 \
  igbinary \
  imagick \
  mailparse \
  msgpack \
  oauth \
  propro \
  raphf \
  redis \
  ssh2-1.2.0 \
  xdebug-3.0.0 \
  yaml

# Install Composer.
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && ln -s $(composer config --global home) /root/composer

ENV PATH=$PATH:/root/composer/vendor/bin COMPOSER_ALLOW_SUPERUSER=1

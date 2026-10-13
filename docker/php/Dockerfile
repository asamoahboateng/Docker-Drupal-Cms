FROM php:8.3-apache-bookworm

# Match www-data to the host user so files in ./app stay editable on the host.
ARG UID=1000
ARG GID=1000

RUN apt-get update && apt-get install -y --no-install-recommends \
        git unzip patch curl ca-certificates mariadb-client msmtp \
        libzip-dev libpng-dev libjpeg62-turbo-dev libfreetype6-dev libwebp-dev libicu-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
    && docker-php-ext-install -j"$(nproc)" gd pdo_mysql zip intl opcache bcmath exif \
    && pecl install apcu \
    && docker-php-ext-enable apcu \
    && a2enmod rewrite headers expires remoteip \
    && rm -rf /var/lib/apt/lists/* /tmp/pear

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

ENV APACHE_DOCUMENT_ROOT=/var/www/html/web \
    COMPOSER_HOME=/var/www/.composer \
    COMPOSER_MEMORY_LIMIT=-1 \
    PATH="/var/www/html/vendor/bin:${PATH}"

RUN sed -ri 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf \
    && groupmod -o -g "${GID}" www-data \
    && usermod -o -u "${UID}" -g "${GID}" www-data \
    && mkdir -p /var/www/.composer \
    && chown -R www-data:www-data /var/www

COPY php.ini /usr/local/etc/php/conf.d/zz-drupal.ini
COPY apache-drupal.conf /etc/apache2/conf-enabled/drupal.conf
COPY entrypoint.sh /usr/local/bin/drupal-entrypoint
RUN chmod +x /usr/local/bin/drupal-entrypoint

WORKDIR /var/www/html
ENTRYPOINT ["drupal-entrypoint"]
CMD ["apache2-foreground"]

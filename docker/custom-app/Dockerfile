FROM php:8.3-apache
RUN apt-get update && apt-get install -y --no-install-recommends default-mysql-client git unzip libzip-dev && docker-php-ext-install mysqli pdo pdo_mysql zip && rm -rf /var/lib/apt/lists/*
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer
WORKDIR /var/www/html
COPY composer.json .
RUN composer install --no-interaction --prefer-dist || true
COPY src/ .

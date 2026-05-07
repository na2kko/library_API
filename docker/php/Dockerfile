# =========================
# BASE
# =========================
FROM php:8.4-fpm-alpine AS base

RUN apk add --no-cache \
    nodejs \
    npm \
    libpng-dev \
    libjpeg-turbo-dev \
    freetype-dev \
    libwebp-dev \
    libzip-dev \
    sqlite-dev \
    zip \
    unzip \
    openssl

RUN docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp
RUN docker-php-ext-install \
    pdo \
    pdo_mysql \
    pdo_sqlite \
    bcmath \
    gd \
    zip

COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

WORKDIR /usr/src/library-api

# =========================
# TEST IMAGE
# =========================
FROM base AS testing

COPY composer.json composer.lock ./

RUN composer install --no-scripts --no-interaction --prefer-dist

COPY package.json package-lock.json ./

RUN npm install

COPY . .

RUN composer dump-autoload --optimize

RUN php artisan package:discover

RUN npm run build

CMD ["php", "artisan", "test"]

# =========================
# PRODUCTION IMAGE
# =========================
FROM base AS production

WORKDIR /usr/src/library-api

COPY composer.json composer.lock ./

RUN composer install \
    --no-dev \
    --no-scripts \
    --optimize-autoloader \
    --no-interaction \
    --prefer-dist

COPY package.json package-lock.json ./

RUN npm install

COPY . .

RUN composer dump-autoload --optimize

RUN php artisan package:discover --ansi

RUN npm run build

RUN chown -R www-data:www-data storage bootstrap/cache

EXPOSE 9000

COPY docker/php/entrypoint.sh /usr/local/bin

RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["entrypoint.sh"]

CMD ["/usr/local/sbin/php-fpm"]
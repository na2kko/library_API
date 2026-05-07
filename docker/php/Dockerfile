FROM php:8.4-fpm-alpine

RUN apk add --no-cache \
    nodejs \
    npm \
    libpng-dev \
    libjpeg-turbo-dev \
    freetype-dev \
    libwebp-dev \
    libzip-dev \
    zip \
    unzip \
    openssl

RUN docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp
RUN docker-php-ext-install pdo pdo_mysql bcmath gd zip

COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

WORKDIR /usr/src/library-api

COPY composer.json composer.lock ./
RUN composer install --no-scripts --no-autoloader

COPY package.json package-lock.json ./
RUN npm install

COPY . .

RUN composer dump-autoload --optimize
RUN npm run build

RUN chown -R www-data:www-data storage bootstrap/cache

EXPOSE 9000

COPY docker/php/entrypoint.sh /usr/local/bin
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT [ "entrypoint.sh" ]
CMD ["/usr/local/sbin/php-fpm"]
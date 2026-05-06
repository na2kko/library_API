#!/bin/sh

chown -R www-data:www-data storage bootstrap/cache

php artisan migrate --force

exec "$@"
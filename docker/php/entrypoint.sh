#!/bin/sh

set -e

chown -R www-data:www-data storage bootstrap/cache

php artisan config:clear
php artisan route:clear
php artisan view:clear

php artisan migrate --force

php artisan config:cache
php artisan route:cache

exec "$@"
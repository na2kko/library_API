#!/bin/sh

set -e

if ["$1" = "php-fpm"]; then
    echo "corriendo migraciones..."
    php artisan migrate --force
fi

exec "$@"
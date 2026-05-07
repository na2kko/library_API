#!/bin/sh

set -e

if [-d "storage"]; then
    chown -R www-data:www-data storage bootstrap/cache
fi

exec "$@"
#!/bin/sh

if [ ! -d vendor ] || [ -z "$(ls -A vendor)" ]; then
    composer install --no-progress --no-interaction
fi

if [ ! -f .env ]; then
    cp .env.example .env
fi

php artisan migrate
if ! grep -q '^APP_KEY=' .env || [ -z "$(grep '^APP_KEY=' .env | cut -d '=' -f2)" ]; then
    php artisan key:generate
fi

php artisan optimize:clear

exec php-fpm


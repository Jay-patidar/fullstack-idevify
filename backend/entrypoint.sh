#!/bin/sh
set -e

echo "==> Running Django database migrations..."
python manage.py migrate --noinput

echo "==> Collecting static files..."
python manage.py collectstatic --noinput --clear || true

echo "==> Starting application..."
exec "$@"

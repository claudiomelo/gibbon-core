#!/bin/bash
echo "Fixing permissions for uploads directory..."
mkdir -p /var/www/html/uploads/cache
chown -R www-data:www-data /var/www/html/uploads
chmod -R 775 /var/www/html/uploads
exec "$@"

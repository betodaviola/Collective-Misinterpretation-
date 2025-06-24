#!/bin/sh
# This script fixes the ownership every time the container starts

echo "Fixing ownership of /var/www..."
chown -R www-data:www-data /var/www

# Now run the main command
exec "$@"

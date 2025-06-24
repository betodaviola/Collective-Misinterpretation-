FROM php:8.4.9RC1-fpm-bookworm

RUN apt-get update && apt-get install -y \
    git \
    curl \
    zip \
    unzip \
    && rm -rf /var/lib/apt/lists/*  
# last line removes files left behing in the system
    
WORKDIR /var/www
####WONT WORK ON LINUX WITHOUT SECTION BELOW THIS LINE
# Copy files from your host into the image
# (you can remove the volume mount later if this is for deployment).
COPY . /var/www/

# Ensure files are owned by the `www-data` user
RUN chown -R www-data:www-data /var/www

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Use the entrypoint script
ENTRYPOINT ["/entrypoint.sh"]

# Default command
CMD ["php-fpm"]
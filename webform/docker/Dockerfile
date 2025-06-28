FROM php:8.4.9RC1-fpm-bookworm

RUN apt-get update && apt-get install -y \
    git \
    curl \
    zip \
    unzip \
    jq \
    && rm -rf /var/lib/apt/lists/*  
# last line removes files left behing in the system
    
WORKDIR /var/www

# Default command
CMD ["php-fpm"]
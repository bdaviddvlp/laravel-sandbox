# Use the official PHP image as the base image
FROM php:8.1-fpm

# Install system dependencies and PHP extensions
RUN apt-get update && apt-get install -y \
    nginx \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    zip \
    unzip \
    sudo \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd pdo pdo_mysql

# Configure Nginx
COPY nginx/default.conf /etc/nginx/sites-available/default
# RUN ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled

# Set the working directory to /var/www
WORKDIR /var/www

# Copy composer.lock and composer.json to install dependencies
COPY ./* /var/www/

COPY .env.example /var/www/.env

RUN pwd ; sleep 6 ; ls -la ; sleep 6

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN composer config -g repo.packagist composer https://packagist.org

# RUN composer run refresh

# Install Laravel dependencies
RUN composer install --no-scripts

RUN pwd ; sleep 6 ; ls -la ; sleep 6

RUN composer install

# Expose port 80 for Nginx
EXPOSE 80

# Start Nginx and PHP-FPM
CMD service nginx start && php-fpm

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
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd pdo pdo_mysql

# Configure Nginx
COPY nginx/default.conf /etc/nginx/sites-available/default
# RUN ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled

# Set the working directory to /var/www
WORKDIR /var/www

# Copy composer.lock and composer.json to install dependencies
COPY composer.json /var/www/

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install Laravel dependencies
RUN composer update

# Expose port 80 for Nginx
EXPOSE 80

# Start Nginx and PHP-FPM
CMD service nginx start && php-fpm

# Define a volume to mount the Laravel project directory from the host
VOLUME ["/opt/jenkins/jenkins_home/workspace/laravel-sandbox:/var/www"]

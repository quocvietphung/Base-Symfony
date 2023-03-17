FROM php:8.1

# Install necessary extensions
RUN docker-php-ext-install pdo_mysql opcache

# Install necessary packages
RUN apt-get update && \
    apt-get install -y \
        git \
        zip \
        unzip

# Install Symfony CLI
RUN wget https://get.symfony.com/cli/installer -O - | bash

# Set up the application directory
WORKDIR /var/www/app

# Install Symfony and its dependencies
COPY composer.json composer.lock ./
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
    composer install --prefer-dist --no-scripts --no-dev --no-autoloader && \
    composer clear-cache

COPY . .

# Build the autoloader
RUN composer dump-autoload --no-scripts --no-dev --optimize

# Set up the Symfony environment
ENV APP_ENV=prod

# Expose the port for the Symfony server
EXPOSE 8000

# Start the Symfony server
CMD ["symfony", "server:start", "--no-tls", "--port=8000", "--allow-http"]

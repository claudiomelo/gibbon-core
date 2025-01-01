# Use a imagem oficial do PHP com Apache
FROM php:7.4-apache

# Instalar dependências necessárias
RUN apt-get update && apt-get install -y \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libzip-dev \
    libicu-dev \
    libonig-dev \
    gettext \
    unzip \
    git \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd zip pdo pdo_mysql mysqli intl opcache gettext \
    && a2enmod rewrite

# Instalar o Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copiar o código do projeto (apenas para instalação inicial)
COPY . /var/www/html/

# Instalar dependências do Composer antes de sobrescrever
WORKDIR /var/www/html/
RUN composer install --no-dev --optimize-autoloader

# Ajustar permissões
RUN chown -R www-data:www-data /var/www/html/

# Configurar o PHP
RUN echo "session.gc_maxlifetime = 3600" >> /usr/local/etc/php/php.ini
RUN echo "session.cookie_lifetime = 3600" >> /usr/local/etc/php/php.ini

# Expor a porta 80
EXPOSE 80

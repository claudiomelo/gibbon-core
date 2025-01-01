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
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd zip pdo pdo_mysql mysqli intl opcache gettext \
    && a2enmod rewrite

# Copiar o código do Gibbon para dentro do contêiner
COPY . /var/www/html/

# Permitir acesso ao diretório
RUN chown -R www-data:www-data /var/www/html/

RUN echo "session.gc_maxlifetime = 3600" >> /usr/local/etc/php/php.ini
RUN echo "session.cookie_lifetime = 3600" >> /usr/local/etc/php/php.ini

# Definir o diretório de trabalho
WORKDIR /var/www/html/

# Expor a porta 80
EXPOSE 80

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

# Copiar o código do projeto
COPY . /var/www/html/

# Copiar o script de permissões
COPY init-permissions.sh /usr/local/bin/init-permissions.sh
RUN chmod +x /usr/local/bin/init-permissions.sh

# Instalar dependências do Composer
WORKDIR /var/www/html/
RUN composer install --no-dev --optimize-autoloader

# Adjust permissions for the Gibbon root directory
RUN chown -R www-data:www-data /var/www/html && \
    chmod -R 775 /var/www/html

# Configurar o PHP
RUN echo "session.gc_maxlifetime = 3600" >> /usr/local/etc/php/php.ini
RUN echo "session.cookie_lifetime = 3600" >> /usr/local/etc/php/php.ini

# Usar www-data para rodar os processos
USER www-data

# Executar o script de permissões antes de iniciar o Apache
CMD ["/bin/bash", "-c", "sudo chown -R www-data:www-data /var/www/html && sudo chmod -R 775 /var/www/html && apache2-foreground"]

# Expor a porta 80
EXPOSE 80

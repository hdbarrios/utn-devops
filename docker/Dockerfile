# Nombre base de la imagen Docker que vamos a utilizar
# En este caso la imagen es la que está en el repositorio de Hub de Docker y 
# es la imagen oficial de PHP. El resto de la configuración la tendremos en el 
# archivo docker-compose.yml
FROM php:7.0-apache

RUN usermod -u 1000 www-data
RUN groupmod -g 1000 www-data

# Install GD
RUN  apt update --fix-missing && apt upgrade -y \
    && apt-get install -y libfreetype6-dev libjpeg62-turbo-dev libmagickwand-dev \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install gd \
	&& pecl install imagick \
	&& apt-get install vim apt-utils -y

# Install MCrypt
RUN apt-get update \
    && apt-get install -y libmcrypt-dev \
    && docker-php-ext-install mcrypt

# Install Mysql
RUN docker-php-ext-install mysqli pdo_mysql

# Install Git
RUN apt-get update \
    && apt-get install -y git

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer

# Install Intl
RUN apt-get update \
    && apt-get install -y libicu-dev \
    && docker-php-ext-install intl

# Install MySQL CLI Client
RUN apt-get update \
    && apt-get install -y mysql-client

#ENV XDEBUG_ENABLE 0
#RUN pecl config-set preferred_state beta \
#    && pecl install -o -f xdebug \
#    && rm -rf /tmp/pear \
#    && pecl config-set preferred_state stable

# Install mbstring
RUN docker-php-ext-install mbstring

# Install soap
RUN apt-get update \
    && apt-get install -y libxml2-dev \
    && docker-php-ext-install soap

# Install opcache
RUN docker-php-ext-install opcache

# Install PHP zip extension
RUN docker-php-ext-install zip


# Install xsl
RUN apt-get update \
    && apt-get install -y libxslt-dev \
    && docker-php-ext-install xsl

# Define PHP_TIMEZONE env variable
#ENV PHP_TIMEZONE Europe/Paris

# Configure Apache Document Root
ENV APACHE_DOC_ROOT /var/www/html

# Enable Apache mod_rewrite
RUN a2enmod rewrite

# Install ssmtp Mail Transfer Agent
#RUN apt-get update \
#    && apt-get install -y ssmtp \
#    && apt-get clean \
#    && echo "FromLineOverride=YES" >> /etc/ssmtp/ssmtp.conf \
#    && echo 'sendmail_path = "/usr/sbin/ssmtp -t"' > /usr/local/etc/php/conf.d/mail.ini

########################################################################################################################

# Start!
#COPY ./start /usr/local/bin/
#CMD ["start"]

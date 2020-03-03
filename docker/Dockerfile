# Nombre base de la imagen Docker que vamos a utilizar
# En este caso la imagen es la que está en el repositorio de Hub de Docker y 
# es la imagen oficial de PHP. El resto de la configuración la tendremos en el 
# archivo docker-compose.yml
#FROM php:7.0-apache
FROM php:7.2.2-apache 

# Instalo paquetes complementarios
RUN apt-get update && apt-get install -y vim libmcrypt-dev \
    mariadb-client libmagickwand-dev git 
    #mariadb-client libmagickwand-dev --no-install-recommends \
    # git \
    #&& pecl install imagick \
    #&& docker-php-ext-enable imagick \
    #&& docker-php-ext-install mcrypt pdo_mysql zip 

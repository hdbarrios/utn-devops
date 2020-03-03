#!/bin/bash

### Aprovisionamiento de software ###

# Actualizo los paquetes de la maquina virtual
sudo apt-get update

# Instalo un servidor web
#sudo apt-get install -y apache2 
# --
# se desintala servidor apache en la vm de virtual box en ubunto
if [ -x "$(command -v apache2)" ]; then
	sudo apt-get remove --purge apache2 -y
	sudo apt-get autoremove -y
fi

# se crean los directorios para BD y firewall
if [ ! -d "/var/db/mysql" ] ; then
	sudo mkdir -p /var/db/mysql
fi

if [ ! -d "/tmp/ufw" ] ; then
	sudo mv -f /tmp/ufw /etc/default/ufw
fi


### Configuración del entorno ###
##Genero una partición swap. Previene errores de falta de memoria
if [ ! -f "/swapdir/swapfile" ]; then
	sudo mkdir /swapdir
	cd /swapdir
	sudo dd if=/dev/zero of=/swapdir/swapfile bs=1024 count=2000000
	sudo mkswap -f  /swapdir/swapfile
	sudo chmod 600 /swapdir/swapfile
	sudo swapon swapfile
	echo "/swapdir/swapfile       none    swap    sw      0       0" | sudo tee -a /etc/fstab /etc/fstab
	sudo sysctl vm.swappiness=10
	echo vm.swappiness = 10 | sudo tee -a /etc/sysctl.conf
fi

# ruta raíz del servidor web
if [ ! -d "/var/www/" ] ; then 
	sudo mkdir -p /var/www
fi

APACHE_ROOT="/var/www"
# ruta de la aplicación
APP_PATH="$APACHE_ROOT/utn-apps"

# se descarga la app
cd $APACHE_ROOT
sudo git clone -b unidad-2 https://github.com/kratos0804/utn-apps.git .
#cd $APP_PATH
#sudo git checkout unidad-1 
#sudo git clone -b unidad-2 https://github.com/Fichen/utn-devops-app.git .

# --------------------------------------------------------------------------
# instalacion de docker

if [ ! -x "$(command -v docker)" ] ; then
	sudo apt-get update ; sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
	# se configura repositorio de docker
	curl -fsSL "https://download.docker.com/linux/ubuntu/gpg" > /tmp/docker_gpg
	sudo apt-key add < /tmp/docker_gpg && sudo rm -f /tmp/docker_gpg
	sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

	#se actualiza los paquetes
	sudo apt-get update -y

	#Instalo docker desde el repositorio oficial
        sudo apt-get install -y docker-ce docker-compose

        #Lo configuro para que inicie en el arranque
        sudo systemctl enable docker
fi

echo "vagrant ssh: "
vagrant ssh

#echo " "
cd /vagrant/docker/

pwd

echo " "
ls -ltra

sudo docker ps -a | grep -v CONTAINER | while read line ; do sudo docker rm `echo $line | awk '{print$1}'` ; done
sudo docker images | grep -v REPOSITORY | while read line ; do sudo docker image rm  `echo $line | awk '{print$3}'` ; done

echo " "
echo "creando docker"
sudo docker-compose up -d

echo " "
echo "docker creados"
sudo docker ps
sudo docker ps -a

echo " ------------------------------------------------------------- "
echo "IP DE BASE DE DATOS"
sudo docker inspect `sudo docker ps | grep mysql | awk '{print$1}'` | grep IPAddress | tail -1 | awk '{print$2}' | sed 's/\"//g' | sed 's/\,//g'

echo " ------------------------------------------------------------- "
echo "IP WEB SERVER"
sudo docker inspect `sudo docker ps | grep php | awk '{print$1}'` | grep IPAddress | tail -1 | awk '{print$2}' | sed 's/\"//g' | sed 's/\,//g'


#echo " "
#sudo docker exec -i apache2_php cd /var/www/html/myapp

sudo docker exec -i db_mysql mysql -uroot -proot devops_app < /vagrant/docker/configs/mysql/script.sql

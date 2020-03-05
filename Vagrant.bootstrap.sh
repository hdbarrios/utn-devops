#!/bin/bash

### Aprovisionamiento de software ###

# Actualizo los paquetes de la maquina virtual
echo "etapa 1:"
sudo apt-get update ; sudo apt-get upgrade

# Instalo un servidor web
#sudo apt-get install -y apache2 
# --
# se desintala servidor apache en la vm de virtual box en ubunto
if [ -x "$(command -v apache2)" ]; then
echo "etapa 1.1:"
	sudo apt-get remove --purge apache2 -y
	sudo apt-get autoremove -y
fi

# se crean los directorios para BD y firewall
if [ ! -d "/var/db/mysql" ] ; then
echo "etapa 1.2:"
	sudo mkdir -p /var/db/mysql
fi

if [ ! -d "/tmp/ufw" ] ; then
echo "etapa 1.3:"
	sudo mv -f /tmp/ufw /etc/default/ufw
fi


### Configuración del entorno ###
##Genero una partición swap. Previene errores de falta de memoria
if [ ! -f "/swapdir/swapfile" ]; then
echo "etapa 1.4:"
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
echo "etapa 1.5:"
	sudo mkdir -p /var/www
fi

echo "etapa 2:"
APACHE_ROOT="/var/www"
# ruta de la aplicación
APP_PATH="$APACHE_ROOT/utn-apps"

# se descarga la app
cd $APACHE_ROOT
sudo git clone -b unidad-2 https://github.com/kratos0804/utn-apps.git .
#sudo git clone -b unid2-dd https://github.com/kratos0804/utn-apps.git .
#cd $APP_PATH
#sudo git checkout unidad-1 
#sudo git clone -b unidad-2 https://github.com/Fichen/utn-devops-app.git .

# --------------------------------------------------------------------------
# instalacion de docker

echo "etapa 2.1:"
if [ ! -x "$(command -v docker)" ] ; then
	sudo apt-get update ; sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
	# se configura repositorio de docker
	curl -fsSL "https://download.docker.com/linux/ubuntu/gpg" > /tmp/docker_gpg
	sudo apt-key add < /tmp/docker_gpg && sudo rm -f /tmp/docker_gpg
	sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

	#se actualiza los paquetes
	sudo apt-get update -y

	#Instalo docker desde el repositorio oficial
        sudo apt-get install -y docker-ce docker-compose golang-github-docker-libnetwork-dev \
		golang-github-containerd-docker-containerd-dev golang-github-docker-engine-api-dev ruby-docker-api \
		docker-registry libnss-docker

        #Lo configuro para que inicie en el arranque
        sudo systemctl enable docker

	sudo docker --version
	sudo docker-compose --version

	sudo docker-compose migrate-to-labels
	sudo docker-compose --version

fi

echo " ========================================================================" 

echo "etapa 3:"

echo "vagrant ssh: "
vagrant ssh

#echo " "
cd /vagrant/docker/

pwd

echo " "
ls -ltra

echo " ========================================================================" 
echo " "
echo " reconstruyendo docker"
if [ `sudo docker ps | wc -l` -gt 1 ] ; then  
	sudo docker ps | grep -v CONTAINER | awk '{print$1}' | while read line ; do sudo docker stop $line ; done
	sudo docker ps -a | grep -v CONTAINER | while read line ; do sudo docker rm `echo $line | awk '{print$1}'` ; done
	sudo docker images | grep -v REPOSITORY | while read line ; do sudo docker image rm  `echo $line | awk '{print$3}'` ; done
fi


echo " ========================================================================"

echo " "
echo "creando docker "
sudo docker-compose stop && docker-compose rm && docker-compose build && docker-compose up -d 	

echo " "
echo "docker activos "
sudo docker ps
echo "docker creados "
sudo docker ps -a

echo " ========================================================================"
echo "IP DE BASE DE DATOS"
sudo docker inspect `sudo docker ps | grep mysql | awk '{print$1}'` | grep IPAddress | tail -1 | awk '{print$2}' | sed 's/\"//g' | sed 's/\,//g'
IP_BD=`sudo docker inspect \`sudo docker ps | grep mysql | awk '{print$1}'\` | grep IPAddress | tail -1 | awk '{print$2}' | sed 's/\"//g' | sed 's/\,//g'`
echo " ========================================================================"
echo "IP WEB SERVER"
sudo docker inspect `sudo docker ps | grep php | awk '{print$1}'` | grep IPAddress | tail -1 | awk '{print$2}' | sed 's/\"//g' | sed 's/\,//g'

# echo " ========================================================================"
# echo "Adecuando db_connect a la IP del contenedor de BD"
# sudo sed -i 's/127.0.0.1/'${IP_DB}'/' /var/www/myapp/src/include/db_connect.php
# #echo " "
# #sudo docker exec -i apache2_php cd /var/www/html/myapp

echo " ========================================================================"

echo "creando DB"
if [ `sudo su -c "ls /var/db/mysql/devops_app | grep welcome | wc -l | awk '{print$1}'"` -gt 2  ] ; then
	echo "db y tabla creada"
else
	echo "ejecutando sript.sql"
	sudo docker exec -i dbmysql mysql -uroot -proot devops_app < /vagrant/docker/configs/mysql/script.sql
fi




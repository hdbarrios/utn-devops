#!/bin/bash

# cargo env desde ./docker/.env

. ./docker/.env

### Aprovisionamiento de software ###

# Actualizo los paquetes de la maquina virtual
echo "etapa 1:"
sudo apt-get update ; sudo apt-get upgrade -y

# se valida si se requiere desintalar apache de la MV
if [ -x "$(command -v apache2)" ]; then
echo "etapa 1.1:"
	sudo apt-get remove --purge apache2 -y
	sudo apt-get autoremove -y
fi

#Aprovisionamiento de software
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common linux-image-extra-virtual-hwe-$(lsb_release -r |awk  '{ print $2 }') linux-image-extra-virtual

# Muevo el archivo de configuración de firewall al lugar correspondiente
if [ ! -d "/tmp/ufw" ] ; then
echo "etapa 1.3:"
	sudo mv -f /tmp/ufw /etc/default/ufw
fi

# Muevo el archivo hosts. En este archivo esta asociado el 
# nombre de dominio con una dirección
# ip para que funcione las configuraciones de Puppet
if [ -f "/tmp/etc_hosts.txt" ]; then
	sudo mv -f /tmp/etc_hosts.txt /etc/hosts
fi

# se crean los directorios para BD y firewall
if [ ! -d "/var/db/mysql" ] ; then
echo "etapa 1.2:"
	sudo mkdir -p /var/db/mysql
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

	sudo docker-compose --version

fi

echo " ========================================================================" 


###### Instalación de Puppet ######
#configuración de repositorio
if [ ! -x "$(command -v puppet)" ]; then

	#### Instalacion puppet master
  #Directorios
  PUPPET_DIR="/etc/puppet"
  ENVIRONMENT_DIR="${PUPPET_DIR}/code/environments/production"
  PUPPET_MODULES="${ENVIRONMENT_DIR}/modules"

	sudo add-apt-repository "deb http://archive.ubuntu.com/ubuntu $(lsb_release -sc) universe"
 	sudo apt-get update
	sudo apt install -y puppetmaster
	
	#### Instalacion puppet agent
	sudo apt install -y puppet
	
  # Esto es necesario en entornos reales para posibilitar la sincronizacion
  # entre master y agents
	sudo timedatectl set-timezone America/Argentina/Buenos_Aires
	sudo apt-get -y install ntp
	sudo systemctl restart ntp

 # Muevo el archivo de configuración de Puppet al lugar correspondiente
    sudo mv -f /tmp/puppet-master.conf $PUPPET_DIR/puppet.conf 
	
 # Estructura de directorios para crear el entorno de Puppet
    sudo mkdir -p $ENVIRONMENT_DIR/{manifests,modules,hieradata}
    sudo mkdir -p $PUPPET_MODULES/docker_install/{manifests,files}
	
 # Estructura de directorios para crear el modulo de Jenkins
    sudo mkdir -p $PUPPET_MODULES/jenkins/{manifests,files}

# muevo los archivos que utiliza Puppet
    sudo mv -f /tmp/site.pp $ENVIRONMENT_DIR/manifests #/etc/puppet/manifests/
    sudo mv -f /tmp/init.pp $PUPPET_MODULES/docker_install/manifests/init.pp
    sudo mv -f /tmp/env $PUPPET_MODULES/docker_install/files
    sudo mv -f /tmp/init_jenkins.pp $PUPPET_MODULES/jenkins/manifests/init.pp
    sudo mv -f /tmp/jenkins_default $PUPPET_MODULES/jenkins/files/jenkins_default
    sudo mv -f /tmp/jenkins_init_d $PUPPET_MODULES/jenkins/files/jenkins_init_d

    sudo cp /usr/share/doc/puppet/examples/etckeeper-integration/*commit* $PUPPET_DIR
    sudo chmod 755 $PUPPET_DIR/etckeeper-commit-p*
fi


sudo ufw allow 8140/tcp
sudo ufw allow 8141/tcp
sudo ufw allow 8142/tcp

# al detener e iniciar el servicio se regeneran los certificados
echo "Reiniciando servicios puppetmaster y puppet agent"
sudo systemctl stop puppetmaster && sudo systemctl start puppetmaster
sudo systemctl stop puppet && sudo systemctl start puppet


# limpieza de configuración del dominio utn-devops.localhost es nuestro nodo agente.
# en nuestro caso es la misma máquina
sudo puppet node clean utn-devops.localhost

# Habilito el agente
sudo puppet agent --certname utn-devops.localhost --enable

echo " ========================================================================" 

echo "etapa 3:"

echo "vagrant ssh: "
vagrant ssh

#echo " "
cd /vagrant/docker/

pwd

echo " "
ls -ltra

echo " "
echo " reconstruyendo docker"
if [ `sudo docker ps | wc -l` -gt 1 ] ; then  
	sudo docker ps | grep -v CONTAINER | awk '{print$1}' | while read line ; do sudo docker stop $line ; done
	sudo docker ps -a | grep -v CONTAINER | while read line ; do sudo docker stop `echo ${line} | awk '{print$1}'` ; done
	sudo docker ps -a | grep -v CONTAINER | while read line ; do sudo docker rm `echo ${line} | awk '{print$1}'` ; done
	sudo docker images | grep -v REPOSITORY | while read line ; do sudo docker image rm  `echo ${line} | awk '{print$3}'` ; done
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

echo " ========================================================================"

sleep 60
echo "creando DB"
sudo docker exec -i dbmysql mysql -uroot -proot devops_app < /vagrant/docker/configs/mysql/script.sql

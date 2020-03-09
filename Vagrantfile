# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  # Con esto le indicamos a Vagrant ue vaya al directorio de "cajas" (boxes) que contiene su Atlas e instale un
  # Ubuntu 64 bits mediante el gestor de maquinas virtuales VirtualBox
  # El directorio completo de boxes se puede ver en la siguiente URL atlas.hashicorp.com/boxes/search
  config.vm.box = "ubuntu/bionic64"
  #config.vm.box = "ubuntu/xenial64"

  config.vm.network "forwarded_port", guest: 8081, host: 8081
  config.vm.network "forwarded_port", guest: 4400, host: 4400

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # configuración del nombre de maquina 
  config.vm.hostname = "apps.localhost"
  config.vm.provider "virtualbox" do |v|
	v.name = "utn-apps-vagrant-ubuntu-U2"
  end
  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"
  # 
  # Mapeo de directorios que se comparten entre la maquina virtual y nuestro equipo. En este caso es
  # el propio directorio donde está el archivo  y el directorio "/vagrant" dentro de la maquina virtual.
  config.vm.synced_folder ".", "/vagrant"


  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  config.vm.provider "virtualbox" do |vb|
  #   # Display the VirtualBox GUI when booting the machine
  #   vb.gui = true
  #
  #   
  # Customize the amount of memory on the VM:
    vb.memory = "1024"
  end
  #
   #
  # View the documentation for the provider you are using for more
  # information on available options.

  # Define a Vagrant Push strategy for pushing to Atlas. Other push strategies
  # such as FTP and Heroku are also available. See the documentation at
  # https://docs.vagrantup.com/v2/push/atlas.html for more information.
  # config.push.define "atlas" do |push|
  #   push.app = "YOUR_ATLAS_USERNAME/YOUR_APPLICATION_NAME"
  # end

  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.
  #config.vm.provision "shell", inline: <<-SHELL
  #  echo "I am provisioning..."
  #  date > /etc/vagrant_provisioned_at
  #SHELL

  # Con esta sentencia lo que hara Vagrant es copiar el archivo a la máquina Ubuntu.
  # Además de usarlo como ejemplo para distinguir dos maneras de aprovisionamiento el archivo contiene
  # una definición del firewall de Ubuntu para permitir el tráfico de red que se redirecciona internamente, configuración
  # necesaria para Docker. Luego será copiado al lugar correcto por el script Vagrant.bootstrap.sh 
  config.vm.provision "file", source: "hostConfigs/ufw", destination: "/tmp/ufw"
  config.vm.provision "file", source: "hostConfigs/etc_hosts.txt", destination: "/tmp/etc_hosts.txt"
  # Archivos de Puppet
  config.vm.provision "file", source: "hostConfigs/puppet/site.pp", destination: "/tmp/site.pp"
  config.vm.provision "file", source: "hostConfigs/puppet/init.pp", destination: "/tmp/init.pp"
  config.vm.provision "file", source: "hostConfigs/puppet/init_jenkins.pp", destination: "/tmp/init_jenkins.pp"
  config.vm.provision "file", source: "hostConfigs/puppet/puppet-master.conf", destination: "/tmp/puppet-master.conf"
  config.vm.provision "file", source: "hostConfigs/puppet/.env", destination: "/tmp/env"
  # Archivo para Jenkins
  config.vm.provision "file", source: "hostConfigs/jenkins/default_jenkins", destination: "/tmp/jenkins_default"
  config.vm.provision "file", source: "hostConfigs/jenkins/init_d", destination: "/tmp/jenkins_init_d"
 
  # Con esta sentencia lo que hara Vagrant es transferir este archivo a la máquina Ubuntu
  # y ejecutarlo una vez iniciado. En este caso ahora tendrá el aprovisionamiento para la instalación de Docker 
  config.vm.provision :shell, path: "Vagrant.bootstrap.sh"
  

end


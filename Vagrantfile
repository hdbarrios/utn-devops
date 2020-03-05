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
    vb.memory = "2048"
  end
  #
  
  config.vm.provision "file", source: "hostConfigs/ufw", destination: "/tmp/ufw"
  
  config.vm.provision :shell, path: "Vagrant.bootstrap.sh"
  

end

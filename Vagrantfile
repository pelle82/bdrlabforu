# -*- mode: ruby -*-
# vi: set ft=ruby :

nodes = {
    'devnode01'  => [1, 201],
    'devnode02'  => [1, 202],
    #'devnode03'  => [1, 203],
    #'devnode04'  => [1, 204],
    #'devnode05'  => [1, 205],
    #'devnode06'  => [1, 206],
}

Vagrant.configure("2") do |config|
    
  config.vm.box = "ubuntu/trusty64"
  config.vm.usable_port_range= 2800..2900 

  nodes.each do |prefix, (count, ip_start)|
    count.times do |i|
      hostname = "%s" % [prefix, (i+1)]
      config.vm.define "#{hostname}" do |box|
        box.vm.hostname = "#{hostname}.braindamage.com"
        box.vm.network :private_network, ip: "172.16.0.#{ip_start+i}", :netmask => "255.255.0.0"
        box.vm.network :private_network, ip: "10.10.0.#{ip_start+i}", :netmask => "255.255.255.0" 
      	box.vm.network :private_network, ip: "192.168.100.#{ip_start+i}", :netmask => "255.255.255.0"
	box.vm.provision "shell", path: "provision/setup.sh" 
      end
    end
  end
end

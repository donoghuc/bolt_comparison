linux_provision = <<SCRIPT
apt-get update
apt-get -y install sudo tree locales
eval 'locale-gen en_US.UTF-8'
SCRIPT

Vagrant.configure("2") do |config|
	config.vm.define :bolt_target do |linux|
	  linux.vm.box = 'ubuntu/xenial64'
	  linux.vm.network :forwarded_port, guest: 22, host: 20022, host_ip: '127.0.0.1', id: 'ssh'
	  linux.vm.provision 'shell', inline: linux_provision
	end

	config.vm.define :ansible_target do |linux|
	  linux.vm.box = 'ubuntu/xenial64'
	  linux.vm.network :forwarded_port, guest: 22, host: 20023, host_ip: '127.0.0.1', id: 'ssh'
	  linux.vm.provision 'shell', inline: linux_provision
	end
end

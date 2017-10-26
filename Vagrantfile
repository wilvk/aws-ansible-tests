# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "fedora/26-cloud-base"
  config.vm.provision "shell", privileged: true,  inline: "sudo yum --verbose update  --setopt \"sslverify=0\"  -y"
  config.vm.provision "shell", privileged: true,  inline: "yum -y install ansible"
  config.vm.provision "shell", privileged: false, inline: "ansible-playbook /vagrant/ansible/main.yml"
end

# -*- mode: ruby -*-
# vi: set ft=ruby :

ENV['VAGRANT_NO_PARALLEL'] = 'yes'

VAGRANT_BOX         = "generic/ubuntu2204"
VAGRANT_BOX_VERSION = "4.2.10"
### Configuration of the control-plane machine ###
CPUS_MASTER         = 2
MEMORY_MASTER       = 2048
### Configuration of the workers machines ###
CPUS_WORKER         = 1
MEMORY_WORKER       = 1024
### Number of the worker machines ###
NUMBER_OF_WORKERS  = 2


Vagrant.configure(2) do |config|

  config.vm.provision "shell", path: "installation\\osConfigurator.sh"

  # Kubernetes Master Server
  config.vm.define "master" do |node|
  
    node.vm.box               = VAGRANT_BOX
    node.vm.box_check_update  = false
    node.vm.box_version       = VAGRANT_BOX_VERSION
    node.vm.hostname          = "master.kube.com"

    node.vm.network "private_network", ip: "172.16.16.100"
  
    node.vm.provider :virtualbox do |v|
      v.name    = "master"
      v.memory  = MEMORY_MASTER
      v.cpus    = CPUS_MASTER
    end
  
    node.vm.provider :libvirt do |v|
      v.memory  = MEMORY_MASTER
      v.nested  = true
      v.cpus    = CPUS_MASTER
    end
  
    node.vm.provision "shell", path: "installation\\masterDeployer.sh"
  
  end


  # Kubernetes Worker Nodes
  (1..NUMBER_OF_WORKERS).each do |i|

    config.vm.define "worker-0#{i}" do |node|

      node.vm.box               = VAGRANT_BOX
      node.vm.box_check_update  = false
      node.vm.box_version       = VAGRANT_BOX_VERSION
      node.vm.hostname          = "worker-0#{i}.kube.com"

      node.vm.network "private_network", ip: "172.16.16.10#{i}"

      node.vm.provider :virtualbox do |v|
        v.name    = "worker-0#{i}"
        v.memory  = MEMORY_WORKER
        v.cpus    = CPUS_WORKER
      end

      node.vm.provider :libvirt do |v|
        v.memory  = MEMORY_WORKER
        v.nested  = true
        v.cpus    = CPUS_WORKER
      end

      node.vm.provision "shell", path: "installation\\workerDeployer.sh"

    end

  end

end

# -*- mode: ruby -*-
# vi: ft=ruby :

require 'rbconfig'
require 'yaml'

# Set your default base box here
DEFAULT_BASE_BOX = 'bento/centos-7.4'
DEFAULT_BASE_CPU = '2'
DEFAULT_BASE_MEM = '2048'


ssh_pub_key = File.readlines("#{Dir.home}/.ssh/id_rsa.pub").first.strip
$ssh_key = <<SSHKEY
    if grep -Fxq "#{ssh_pub_key}" /home/vagrant/.ssh/authorized_keys
      then
        echo "#################################"
        echo "SSHKey found in /home/vagrant/.ssh/authorized_keys"
        echo "#################################"
      else
        echo "#################################"
        echo "SSHKey not found, adding it now"
        echo "#################################"
        echo #{ssh_pub_key} >> /home/vagrant/.ssh/authorized_keys
        mkdir -p /root/.ssh && echo #{ssh_pub_key} >> /root/.ssh/authorized_keys 
        chown -R root:root /root/.ssh && chmod -R 600 /root/.ssh/
    fi
SSHKEY


$puppet_pre_req = <<MONKEY
    yum install -y epel-release
    yum install -y puppet
    systemctl enable puppet
    systemctl start puppet
MONKEY


$script = <<SCRIPT
    echo
    echo "#################################"
    echo "Installing packages and stuff.."
    echo "#################################"
    yum clean all && yum update -y
    yum install -y --nogpgcheck epel-release
    yum install -y --nogpgcheck git vim docker docker-compose ansible telnet python-virtualenv
    yum groupinstall -y --nogpgcheck "Development tools"

    echo "#################################"
    echo "Configuring docker"
    echo "#################################"
    systemctl enable docker && systemctl start docker
SCRIPT


#
# No changes needed below this point
#

VAGRANTFILE_API_VERSION = '2'
PROJECT_NAME = '/' + File.basename(Dir.getwd)

hosts = YAML.load_file('vagrant_hosts.yml')

def is_windows
  RbConfig::CONFIG['host_os'] =~ /mswin|mingw|cygwin/
end


# Set options for the network interface configuration. All values are
# optional, and can include:
# - ip (default = DHCP)
# - netmask (default value = 255.255.255.0
# - mac
# - auto_config (if false, Vagrant will not configure this network interface
# - intnet (if true, an internal network adapter will be created instead of a
#   host-only adapter)
def network_options(host)
  options = {}

  if host.has_key?('ip')
    options[:ip] = host['ip']
    options[:netmask] = host['netmask'] ||= '255.255.255.0'
  else
    options[:type] = 'dhcp'
  end

  if host.has_key?('mac')
    options[:mac] = host['mac'].gsub(/[-:]/, '')
  end

  if host.has_key?('auto_config')
    options[:auto_config] = host['auto_config']
  end

  if host.has_key?('intnet') && host['intnet']
    options[:virtualbox__intnet] = true
  end

  options
end

def custom_synced_folders(vm, host)
  if host.has_key?('synced_folders')
    folders = host['synced_folders']

    folders.each do |folder|
      vm.synced_folder folder['src'], folder['dest'], folder['options']
    end
  end
end

# }}}

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  hosts.each do |host|
    config.vm.define host['name'] do |node|
      node.vm.box = host['box'] ||= DEFAULT_BASE_BOX
      node.vm.hostname = host['name']
      node.vm.network :private_network, network_options(host)

      custom_synced_folders(node.vm, host)

      node.vm.provider :virtualbox do |vb|
        vb.name   = host['name']        
        vb.cpus   = host['cpus']   ||= DEFAULT_BASE_CPU
        vb.memory = host['memory'] ||= DEFAULT_BASE_MEM
        vb.gui    = host['gui']    ||= false                             ## Display the VirtualBox GUI when booting the machine
        vb.customize ['modifyvm', :id, '--groups', PROJECT_NAME]         ## Group all VMs into same group name 
        vb.customize ["modifyvm", :id, "--vram", "128"]                  ## Video memory 128MB - to allow high resolution support
        vb.customize ["modifyvm", :id, "--hwvirtex", "on"]               ## Enable Hardware virt extensions
        vb.customize ["modifyvm", :id, "--accelerate3d", "on"]           ## Enable Hardware 3D acceleration
        vb.customize ["modifyvm", :id, "--nicpromisc2", "allow-all"]     ## Enable promisc mode on ETH1 to allow traffic between VM and your laptop
        vb.customize ["modifyvm", :id, "--clipboard", "bidirectional"]   ## Enable shared clipboard between VM and your laptop for easy copy/paste of text
        vb.customize ["modifyvm", :id, "--draganddrop", "bidirectional"] ## Allow drag&drop of files between VM and your laptop (may not work..)
      end
      
      ## Setup SSH Keys for easy access
      node.vm.provision "shell", inline: $ssh_key
      node.vm.provision "shell", inline: $puppet_pre_req

      if host.has_key?('script')  ## if host has playbook configured in yaml file
        node.vm.provision "shell", inline: host['script']
      end

      if host.has_key?('playbook')  ## if host has playbook configured in yaml file
        node.vm.provision "ansible" do |ansible|
          ansible.playbook = host['playbook']
          ansible.become = true
        end
      end

      if host.has_key?('puppetcfg')  ## if host has puppet configured in yaml file
        # node.vm.synced_folder("puppet/", "/tmp/vagrant-puppet/")
        node.vm.provision "puppet" do |puppet|
          puppet.manifest_file      = host['puppetcfg']
          puppet.manifests_path     = "puppet/manifests"
          puppet.module_path        = "puppet/modules"
          # puppet.working_directory = "/tmp/vagrant-puppet/"
          puppet.options            = "--verbose --debug"
        end
      end
      
    end 
  end
end
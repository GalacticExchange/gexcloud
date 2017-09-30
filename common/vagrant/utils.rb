ENV['VAGRANT_DEFAULT_PROVIDER']="virtualbox"

# Function to check whether VM was already provisioned
def provisioned?(vm_name, provider='virtualbox')
  File.exist?(".vagrant/machines/#{vm_name}/#{provider}/action_provision")
end

def cpu_count
  return Java::Java.lang.Runtime.getRuntime.availableProcessors if defined? Java::Java
  return File.read('/proc/cpuinfo').scan(/^processor\s*:/).size if File.exist? '/proc/cpuinfo'
  require 'win32ole'
  WIN32OLE.connect("winmgmts://").ExecQuery("select * from Win32_ComputerSystem").NumberOfProcessors
rescue LoadError
  Integer `sysctl -n hw.ncpu 2>/dev/null` rescue 1
end

def set_hosts_entries(m, settings, global_settings)
  cmd = "grep -q -F '#{settings[:PRIVATE_IP]}' /etc/hosts || bash -c 'cat /vagrant/cluster.hosts >> /etc/hosts'"
  m.vm.provision "hostentries", type: "shell", inline: cmd
end


def set_default_route(m, settings)
  m.vm.provision "setdefault", type: "shell", run: "always", inline: "ip route replace default via "+ settings[:GATEWAY]
  #delete_default_vagrant_route m, settings
end

def delete_default_vbox_route(m, settings)
  m.vm.provision "deletedefault", type: "shell", run: "always", inline: "eval `route -n | awk '{ if ($8 ==\"eth0\" && $2 != \"0.0.0.0\") print \"route del default gw \" $2; }'`"
end


def configure_ram(m, settings)
  m.vm.provider "virtualbox" do |vb|
    #   vb.gui = true

    ram_size = settings[:RAM_SIZE]
    if provisioned? settings[:NAME]
    else
      if settings[:RAM_SIZE].to_i < 6000
        ram_size = "6000"
      end
    end

    puts "Using memory:  #{ram_size} MB"
    vb.memory = ram_size
    count = cpu_count
#    if count > 16
#     count = 17
#  end
    vb.cpus = count - 1

    puts "Using cpus:  #{count - 1}"


    vb.customize ["modifyvm", :id, "--nicpromisc1", "allow-all"]
    vb.customize ["modifyvm", :id, "--nicpromisc2", "allow-all"]
    vb.customize ["modifyvm", :id, "--nicpromisc3", "allow-all"]

  end
end

def enable_gui(m)
  m.vm.provider "virtualbox" do |vb|
    vb.gui = true
  end
end

def configure_port_forwards(m, settings)
  pfs = settings[:PORT_FORWARDS]

  pfs.each do |guest_port, host_port|
    m.vm.network "forwarded_port", guest: guest_port, host: host_port
  end if pfs != nil
end

def configure_standard_network(m, settings, global_settings, reverse = false)

  puts "Configuring interfaces \n"
  if reverse

    if settings[:PUBLIC_BRIDGE] != nil
      m.vm.network "public_network", auto_config: false, :bridge => settings[:PUBLIC_BRIDGE]
      m.vm.provision "publicbridge", type: "shell", run: "always", inline: "ifconfig eth1 " + settings[:PUBLIC_IP] + " netmask " + settings[:PUBLIC_MASK] + " up"
    end

    m.vm.network "public_network", auto_config: false, :bridge => settings[:PRIVATE_BRIDGE]
    m.vm.provision "privatebridge", type: "shell", run: "always", inline: "ifconfig eth2 " + settings[:PRIVATE_IP] + " netmask " + settings[:PRIVATE_MASK] + " up"

  else

    m.vm.network "public_network", auto_config: false, :bridge => settings[:PRIVATE_BRIDGE]
    m.vm.provision "privatebridge", type: "shell", run: "always", inline: "ifconfig eth1 " + settings[:PRIVATE_IP] + " netmask " + settings[:PRIVATE_MASK] + " up"

    if settings[:PUBLIC_BRIDGE] != nil
      m.vm.network "public_network", auto_config: false, :bridge => settings[:PUBLIC_BRIDGE]
      m.vm.provision "publicbridge", type: "shell", run: "always", inline: "ifconfig eth2 " + settings[:PUBLIC_IP] + " netmask " + settings[:PUBLIC_MASK] + " up"
    end

  end

  puts "Configuring port forwards \n"
  configure_port_forwards m, settings

  if settings[:GATEWAY] != nil
    puts "Configuring default route \n"
    set_default_route m, settings
  end

  puts "Configuring host entries \n"
  set_hosts_entries m, settings, global_settings

  provision_same_server m

end

def provision_same_server(m)
  puts "Checking if running on the same server\n"
  if File.exist? "/etc/gex/network/SAME_SERVER"
    m.vm.provision "sameserver", type: "shell", run: "always", inline: "/sbin/ip route replace  51.76.0.0/14  via 51.0.1.50"
  end
end

def provision_shell(m, name, cmd)
  m.vm.provision name, type: "shell", run: "always", inline: "#{cmd}"
end

def provision_ansible(m, settings, name, playbook, vars)





    m.vm.provision name, type: "ansible" do |ansible|

      ENV['ANSIBLE_SSH_PIPELINING'] = "1"
      ENV['ANSIBLE_GATHERING'] = "explicit"

      puts settings[:NAME]

      api_ip = API_SETTINGS[settings[:NAME].to_sym][:PRIVATE_IP] ## for nfs mount


      if api_ip == nil || api_ip == ""
        raise Exception "Null api_ip"
      end

      vars[:api_ip] = api_ip

      ansible.playbook = playbook
      ansible.extra_vars = vars
      ansible.raw_arguments = ['-e pipelining=True', '-e gather_facts=False']
      ansible.raw_ssh_args = ['-o ForwardAgent=yes', '-o ControlMaster=auto', '-o ControlPersist=1800s', '-o ControlMaster=auto', '-o StrictHostKeyChecking=no', '-o UserKnownHostsFile=/dev/null']
      #ansible.host_key_checking = false
      #ansible.verbose = true
    end

end


def configure_all_boxes(function_name, all_settings)


  add_all_to_hosts


  Vagrant.configure(2) do |config|


    config.vm.provider "docker" do |d|
      d.image = "kxes/ubuntu-systemd"
      d.has_ssh = false
    end


    global_settings = all_settings[:global_settings]
    all_settings.each do |name, settings|
      if name.to_s == ARGV[1] || name.to_s == ARGV[2]
        if name != :global_settings
            send(function_name, config, settings, global_settings, name)
        end

      end
    end
  end
end

def configure_standard_net_and_ram(m, settings, global_settings, reverse = false)
  configure_standard_network m, settings, global_settings, reverse
  configure_ram m, settings
end


def configure_standard_box_image(config, gs)
    config.vm.box = gs[:BOX_IMAGE]
    config.vm.box_check_update = false
  config.ssh.insert_key=false
  config.ssh.password = gs[:SSH_PASSWORD] if gs[:SSH_PASSWORD] != nil
end


require_relative '../config/config.rb'


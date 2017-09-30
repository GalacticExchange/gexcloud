template '/etc/sensu/conf.d/client.json' do
  source 'client.json.erb'
end

template '/etc/sensu/config.json' do
  source 'config.json.erb'
end

hostname = File.read('/etc/hostname').strip
file '/etc/hostname' do
  content node['node_name']
end

#TODO fx this
bash 'setup hostname' do
  code <<-EOH
    hostnamectl set-hostname #{node.fetch('node_name')}
    sysctl 'kernel.hostname=#{node.fetch('node_name')}'
    sed -i 's/127.0.0.1 localhost/127.0.0.1 #{node.fetch('node_name')}/g' /etc/hosts
    sed -i 's/#{hostname}/#{node.fetch('node_name')}/g' /etc/hosts
  EOH
end

bash 'resolv.conf setup' do
  code <<-EOH
    chattr -i /etc/resolv.conf
    echo "nameserver  #{node['common'].fetch('dns_ip')}" > /etc/resolv.conf
    echo "nameserver  8.8.8.8" >> /etc/resolv.conf
    chattr +i /etc/resolv.conf
  EOH
  not_if {GexUtils.docker_bare_metal?}
end

service 'avahi-daemon' do
  action :restart
end

template '/etc/openvpn/config/client_node.conf' do
  source 'client_vpn.conf.erb'
  variables(
      vpn_server_port: node['host'].fetch('vpn_server_port'),
      vpn_client_ip: node['host'].fetch('vpn_client_ip'),
      vpn_server_ip: node['host'].fetch('vpn_server_ip')
  )
end

template '/etc/systemd/system/vpnclient_node.service' do
  source 'vpnclient_node.service.erb'
  variables(
      interface: `ip route |grep default| awk '{print $5}'`.strip
  )
end

file '/etc/openvpn/config/secret.key' do
  content File.read('/home/vagrant/openvpn/secret.key')
  mode '0775'
end

#execute 'copy secret key' do
#  command 'cp /home/vagrant/openvpn/secret.key /etc/openvpn/config/secret.key'
#end

# TODO !!!!!!!!!!!!!
service 'vpnclient_node' do
  action [:enable, :start]
end

###############################################################################

# 3 wait for vpn to come up
ruby_block 'waiting for vpn to come up..' do
  block do
    GexUtils.wait_for_vpn
  end
end

###############################################################################

# 4 update sensu gems
bash 'update sensu gems' do
  code <<-EOH
    mkdir -p /etc/sensu/
    rm -rf /tmp/framework_templates
    git clone #{FRAMEWORK_TEMPLATES} /tmp/framework_templates
    cp /tmp/framework_templates/node/sensu/Gemfile /etc/sensu
    /opt/sensu/embedded/bin/bundle --gemfile=/etc/sensu/Gemfile
    /bin/cp -rf /tmp/framework_templates/node/sensu/plugins/* /etc/sensu/plugins/
  EOH
end

###############################################################################

# 5
service 'sensu-client' do
  action [:enable, :start]
end

###############################################################################

# check for app only node
return if node.fetch('app_only')


node.default['app'] = node['hadoop']
include_recipe 'gex::container_install'

node.default['app'] = node['hue']
include_recipe 'gex::container_install'
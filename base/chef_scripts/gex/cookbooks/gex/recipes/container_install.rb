
docker_container node['app']['name'] do
  repo node['app']['image_name']
  host_name "#{node['app']['name']}-#{node.fetch('node_name')}"
  command node['is_app_hub'] ? '' : '/etc/bootstrap.sh'
  # noinspection RubyLiteralArrayInspection
  volumes [
              "#{node['app']['name']}_data:/data",
              "#{node['app']['name']}_etc:/etc",
              "#{node['app']['name']}_var_log:/var/log",
              "#{node['app']['name']}_home:/home",
              "#{node['app']['name']}_root:/root"
          ]
  extra_hosts [
                  "#{node.fetch('master_ip')}:#{node.fetch('master_host')}"
              ]
  privileged true

  action :create
end

%w(data etc var_log home root).each do |dir|
  link "/containers/#{node['app']['name']}/#{dir}" do
    to "/var/lib/docker/volumes/#{node['app']['name']}_#{dir}/_data"
    link_type :symbolic
  end
end

cookbook_file "/containers/#{node['app']['name']}/etc/bootstrap.sh" do
  source 'bootstrap.sh'
  mode '0755'
  #action :touch
end

cookbook_file "/containers/#{node['app']['name']}/etc/init.sh" do
  source 'init.sh'
  mode '0755'
end

template "/etc/systemd/system/#{node['app']['name']}.service" do
  source 'app.service.erb'
  variables(
      app_name: "#{node['app']['name']}",
      app_static_ip: node['app']['static_ip']
  )
end

service "#{node['app']['name']}" do
  action [:enable, :start]
end

directory "/containers/#{node['app']['name']}/etc/openvpn/config" do
  action :create
end

template "/containers/#{node['app']['name']}/etc/openvpn/config/client_#{node['app']['name']}.conf" do
  source 'client_vpn.conf.erb'
  variables(
      vpn_server_port: node['app'].fetch('vpn_server_port'),
      vpn_client_ip: node['app'].fetch('vpn_client_ip'),
      vpn_server_ip: node['app'].fetch('vpn_server_ip')
  )
end

template "/etc/systemd/system/vpnclient_#{node['app']['name']}.service" do
  source 'vpnclient_app.service.erb'
  variables(
      app_name: node['app']['name'],
      app_interface_name: GexUtils.get_app_ifname(node['app']['name']),
      app_vpn_client_ip: node['app'].fetch('vpn_client_ip')
  )
end

file "/containers/#{node['app']['name']}/etc/openvpn/config/secret.key" do
  content File.read('/etc/openvpn/config/secret.key')
end

file "/containers/#{node['app']['name']}/etc/openvpn/config/password" do
  content File.read('/etc/openvpn/config/password')
end

execute 'systemctl daemon-reload' do
  command 'systemctl daemon-reload'
end

service "vpnclient_#{node['app']['name']}" do
  action [:enable, :start]
end

ruby_block 'process framework templates' do
  block do
    # TODO get components
    vars = {
        '_components' => []
    }
    $container = node['app']['name']
    $editors = []
    processor = ERBProcessor.new(vars)
    FrameworkTemplates.process_template_trees("#{node['app']['name']}/slave", processor, node['app']['name'])
  end
end
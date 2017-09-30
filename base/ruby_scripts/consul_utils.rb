require 'diplomat'

def consul_ports(cluster_id)
  assert_cluster_id cluster_id
  max = cluster_id.to_i * 5
  arr = (max).downto(max-4).to_a

  {
      dns: 40000 + arr[0],
      http: 40000 + arr[1],
      serf_lan: 40000 + arr[2],
      serf_wan: 40000 + arr[3],
      server: 40000 + arr[4]
  }
end


def consul_connect(cluster_id, host = '51.0.1.8')
  puts "#{host}:#{cluster_id}"
  port = consul_ports(cluster_id)[:http]

  puts "Connecting to Consul (#{host}:#{port})"

  Diplomat.configure do |config|
    config.url = "http://#{host}:#{port}"
  end
  #TODO check connection
  puts 'Done'
end

def consul_create_node(node)
  assert_node(node)
  Diplomat::Kv.put("/nodes/#{node}", '')
  Diplomat::Kv.put("/nodes/#{node}/info", '')
  Diplomat::Kv.put("/nodes/#{node}/containers", '')
end

def consul_create_container_dir(node, container)
  assert_node_container(node, container)
  Diplomat::Kv.put("/nodes/#{node}/containers/#{container}", '')
end

def consul_set_container_ip(node, container, ip)
  assert_node_container(node, container)
  assert_ip ip
  Diplomat::Kv.put("/nodes/#{node}/containers/#{container}/primary_ip", "#{ip}")
end

def consul_set_container_tunnel_ip(node, container, ip)
  assert_node_container(node, container)
  assert_ip ip
  Diplomat::Kv.put("/nodes/#{node}/containers/#{container}/tunnel_ip", "#{ip}")
end

def consul_set_container_vpn_port(node, container, port)
  assert_node_container(node, container)
  assert_port port
  Diplomat::Kv.put("/nodes/#{node}/containers/#{container}/vpn_port", "#{port}")
end

def consul_init_cluster(cluster_id, cluster_name)
  Diplomat::Kv.put('/nodes', '')
  Diplomat::Kv.put('/info/cluster_name', cluster_name)
  Diplomat::Kv.put('/info/cluster_id', cluster_id)

  consul_create_node('cloud')

  FRAMEWORKS.each do |f|
    consul_create_container_dir('cloud', "#{f}-master-#{cluster_name}")
    consul_set_container_ip('cloud', "#{f}-master-#{cluster_name}", get_framework_master_ip(cluster_id, 'hadoop'))
  end
end


def consul_set_node_ip(node, ip)
  assert_node node
  assert_ip ip
  Diplomat::Kv.put("/nodes/#{node}/primary_ip", "#{ip}")
end

def consul_set_node_tunnel_ip(node, ip)
  assert_node node
  assert_ip ip
  Diplomat::Kv.put("/nodes/#{node}/tunnel_ip", "#{ip}")
end

def consul_set_node_vpn_port(node, port)
  assert_node node
  assert_port port
  Diplomat::Kv.put("/nodes/#{node}/vpn_port", "#{port}")
end

def consul_get_container_ip(node, container)
  assert_node_container(node, container)
  assert_ip(Diplomat::Kv.get("/nodes/#{node}/containers/#{container}/primary_ip"))
end

def consul_get_node_ip(node)
  assert_node node
  ip = Diplomat::Kv.get("/nodes/#{node}/primary_ip")
  assert_ip ip
  ip
end

def consul_get_node_tunnel_ip(node)
  assert_node node
  assert_ip(Diplomat::Kv.get("/nodes/#{node}/tunnel_ip"))
end

def consul_get_node_vpn_port(node)
  assert_node node
  assert_nnil(Diplomat::Kv.get("/nodes/#{node}/vpn_port"))
end

def consul_get(p)
  assert_nnil p
  puts "Consul get #{p}"
  Diplomat::Kv.get(p)
end

def consul_get_container_vpn_port(node, container)
  assert_node_container(node, container)
  assert_nnil(Diplomat::Kv.get("/nodes/#{node}/containers/#{container}/vpn_port"))
end

def consul_get_container_tunnel_ip(node, container)
  assert_node_container(node, container)
  assert_ip(Diplomat::Kv.get("/nodes/#{node}/containers/#{container}/tunnel_ip"))
end


def consul_remove_cluster(cluster_id)
  disable_and_remove_service("consul-#{cluster_id}")
  use_container('openvpn')
  dexec("rm -rf /data/consul/consul-#{cluster_id} |true")
end

def consul_set_cluster_data(data)
  data = data.to_json
  Diplomat::Kv.put('/info/cluster_data.json', data)
end

def consul_get_cluster_data
  JSON.parse(Diplomat::Kv.get('/info/cluster_data.json'))
end

def consul_set_node_data(node_data, node_id)
  node_data = node_data.to_json
  Diplomat::Kv.put("/nodes/id/#{node_id}/node_data.json", node_data)
end

def consul_get_node_data(node_id)
  JSON.parse(Diplomat::Kv.get("/nodes/id/#{node_id}/node_data.json"))
end

def consul_set_app_data(app_data, app_id)
  app_data = app_data.to_json
  Diplomat::Kv.put("/apps/id/#{app_id}/app_data.json", app_data)
end

def consul_get_app_data(app_id)
  JSON.parse(Diplomat::Kv.get("/apps/id/#{app_id}/app_data.json"))
end

def consul_delete_lock(server_name)
  Diplomat::Kv.delete("/lock/#{server_name}")
end

def consul_get_env
  consul_get_cluster_data.fetch('_gex_env')
end
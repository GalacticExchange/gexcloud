require 'zookeeper'
# $Id$

$zk = nil

def zport(cluster_id)
  assert_cluster_id cluster_id
  "#{60000 + cluster_id.to_i}"
end

def establish_zookeeper_connection
  cluster_id = get_info('CLUSTER_ID')
  zconnect cluster_id, '51.0.1.8'
end

def zconnect(cluster_id, host = '51.0.1.8')
  puts "#{host}:#{cluster_id}"
  port = zport(cluster_id)
  #is_port_open?(ip, port, milliseconds = 2000)

  puts "Connecting to Zookeeper.new(#{host}:#{port})"
  unless $zk.nil?
    return $zk
  end
  $zk = Zookeeper.new("#{host}:#{port}")
  puts "Done"
  assert_nnil $zk
end

$processor = nil


def zcheckexit(result)
  assert_nnil result
  exit_code = result[:rc]
  puts result.inspect
  assert(result[:rc] == 0, "Non zero exit code #{exit_code} ")
end

def zcreate_node(node)
  assert_node node
  zcreate "/nodes/#{node}"
  zcreate "/nodes/#{node}/info"
  zcreate "/nodes/#{node}/containers"
end

def zcreate(p)
  assert_nnil $zk, p
  puts "Zcreate #{p}"
  result = $zk.create(:path => p)
  # do nothing if dir already exists

  if result[:rc] == -110
    return
  end
  unless result[:rc]
    return
  end

  zcheckexit result
end

def zdelete(p)

  assert_nnil $zk, p
  puts "Zdelete #{p}"
  result = $zk.delete(:path => p)
  zcheckexit result
end

def zput(p, data)
  assert_nnil $zk, p, data
  puts "Zput #{p}, #{data}"
  result = $zk.set(:path => p, :data => data)
  zcheckexit result
end

$z_dictionary = {}

def zget(p)
  assert_nnil $zk, p
  puts "Zget #{p}"

  value = $z_dictionary[p]

  unless value.nil?
    return value
  end

  result = $zk.get(:path => p)

  zcheckexit result

  $z_dictionary[p] = result[:data]

  return result[:data]

end


def zcreate_container_dir(node, container)
  assert_node_container(node, container)
  zcreate "/nodes/#{node}/containers/#{container}"
end

def zremove_container_dir(node, container)
  assert_node_container(node, container)
  zdelete "/nodes/#{node}/containers/#{container}"
end


def zremove_node_dir(node)
  assert_node node
  zdelete "/nodes/#{node}"
end

def zinit_cluster(cluster_id, cluster_name)
  zcreate '/nodes'
  zcreate '/info'
  zcreate '/info/cluster_name'
  zcreate '/info/cluster_id'
  zput '/info/cluster_name', "#{cluster_name}"
  zput '/info/cluster_id', "#{cluster_id}"
  zcreate_node('cloud')

  FRAMEWORKS.each do |f|
    zcreate_container_dir 'cloud', "#{f}-master-#{cluster_name}"
    zset_container_ip 'cloud', "#{f}-master-#{cluster_name}", get_framework_master_ip(cluster_id, 'hadoop')
  end
end

def zremove_cluster(cluster_id)
  remove_services_by_wildcard "zookeeper-#{cluster_id}"
  FileUtils.rm_r "/data/zookeeper/#{cluster_id}"
end

def zcontainer_path(node, container)
  "/nodes/#{node}/containers/#{container}"
end

def zset_container_ip(node, container, ip)
  assert_node_container(node, container)
  assert_ip ip
  zcreate "/nodes/#{node}/containers/#{container}/primary_ip"
  zput "/nodes/#{node}/containers/#{container}/primary_ip", "#{ip}"
end


def zget_container_ip(node, container)
  assert_node_container(node, container)
  assert_ip(zget "/nodes/#{node}/containers/#{container}/primary_ip")
end

def zset_container_tunnel_ip(node, container, ip)
  assert_node_container(node, container)
  assert_ip ip
  zcreate "/nodes/#{node}/containers/#{container}/tunnel_ip"
  zput "/nodes/#{node}/containers/#{container}/tunnel_ip", "#{ip}"
end

def zget_container_tunnel_ip(node, container)
  assert_node_container(node, container)
  assert_ip(zget "/nodes/#{node}/containers/#{container}/tunnel_ip")
end

def zset_container_vpn_port(node, container, port)
  assert_node_container(node, container)
  assert_port port
  zcreate "/nodes/#{node}/containers/#{container}/vpn_port"
  zput "/nodes/#{node}/containers/#{container}/vpn_port", "#{port}"
end

def zget_container_vpn_port(node, container)
  assert_node_container(node, container)
  assert_nnil(zget "/nodes/#{node}/containers/#{container}/vpn_port")
end

def zset_node_tunnel_ip(node, ip)
  assert_node node
  assert_ip ip
  zcreate "/nodes/#{node}/tunnel_ip"
  zput "/nodes/#{node}/tunnel_ip", "#{ip}"
end

def zget_node_tunnel_ip(node)
  assert_node node
  assert_ip(zget "/nodes/#{node}/tunnel_ip")
end

def zset_node_vpn_port(node, port)
  assert_node node
  assert_port port
  zcreate "/nodes/#{node}/vpn_port"
  zput "/nodes/#{node}/vpn_port", "#{port}"
end

def zget_node_vpn_port(node)
  assert_node node
  assert_nnil(zget "/nodes/#{node}/vpn_port")
end

def zset_node_ip(node, ip)
  assert_node node
  assert_ip ip
  zcreate "/nodes/#{node}/primary_ip"
  zput "/nodes/#{node}/primary_ip", "#{ip}"
end

def zget_node_ip(node)
  assert_node node
  ip = zget "/nodes/#{node}/primary_ip"
  assert_ip ip
  ip
end

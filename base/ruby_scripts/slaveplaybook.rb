#! /usr/bin/env ruby 
#  encoding: UTF-8
# $Id$

#This is very latest

require 'json'
require 'open3'


require_relative 'common'
require_relative 'container_service'

def get_interface
  if bare_metal?
    `route |grep default | awk '{print $8}'`.strip
  else
    #return 'eth1'
    'enp0s8' # Ubuntu 16 vagrant second interface
  end
end

def setup_environment

  hostname = File.read('/etc/hostname').strip

  File.write('/etc/hostname', get_node)

  texecs \
  "hostnamectl set-hostname #{get_node}",
  "sysctl 'kernel.hostname=#{get_node}'"
  `/bin/bash -c "sed -i 's/127.0.0.1 localhost/127.0.0.1 #{get_node}/g' /etc/hosts"` #for aws..
  `/bin/bash -c "sed -i 's/#{hostname}/#{get_node}/g' /etc/hosts"`

  unless docker_bare_metal?
    texecs \
 'chattr -i /etc/resolv.conf',
 "echo \"nameserver  #{ARGV[2]}\" > /etc/resolv.conf",
 "echo \"nameserver  8.8.8.8\" >> /etc/resolv.conf",
 'chattr +i /etc/resolv.conf'
  end
  restart_service 'avahi-daemon'

  # noinspection RubyStringKeysInHashInspection
  dictionary = {
      '_hadoop_ipv4' => ARGV[0],
      '_api_ip' => ARGV[1],
      '_dns_ip' => ARGV[2],
      '_cluster_id' => ARGV[3],
      '_node_id' => ARGV[4],
      '_openvpn_ip_address' => ARGV[7],
      '_node_port' => ARGV[8],
      '_vpn_client_ip' => ARGV[9],
      '_vpn_server_ip' => ARGV[10],
      '_vpn_server_port' => ARGV[11],
      '_socks_proxy_ip' => ARGV[12],
      '_static_ips' => ARGV[13],
      '_container_ips' => ARGV[14],
      '_network_mask' => ARGV[15],
      '_gateway_ip' => ARGV[16],
      '_node_overlay_ip' => ARGV[9],
      'HADOOP_TYPE' => get_container_info('TYPE', 'hadoop'),
      '_hostname' => `hostname`,
      '_node_name' => get_node,
      '_interface' => get_interface

  }


  init_vars(dictionary)

  processor = get_processor

  processor.process_template_file '/etc/systemd/system/client_vpn.conf.erb', '/etc/systemd/system', destination: '/etc/openvpn/config/client_node.conf'
  processor.process_template_file '/etc/systemd/system/vpnclient_node.service.erb', '/etc/systemd/system', destination: '/etc/systemd/system/vpnclient_node.service'

  enable_and_start_service('vpnclient_node')

  texec 'cp /home/vagrant/openvpn/secret.key /etc/openvpn/config/secret.key'

  dictionary.each do |key, value|
    ENV[key] = value
  end

  consul_connect(get_info('CLUSTER_ID'))
  add_var('_gex_env', consul_get_env)
  add_var('_cluster_type', consul_get_cluster_data['_cluster_type'])

  ENV['_cluster_name'] = consul_get('/info/cluster_name')

  node_data = consul_get_node_data(get_value('_node_id'))
  return unless node_data['hadoop_app_id']

  add_var('_components', consul_get_cluster_data.fetch('_components'))

  if get_value('_cluster_type') == 'aws'
    add_var('port_neo4j_bolt', node_data.fetch('port_neo4j_bolt'))
  end

  FRAMEWORKS.each do |f|
    ENV["_#{f}_overlay_ip"] = get_vpn_ip_address true, "#{f}"
    ENV["_#{f}_tunnel_ip"] = get_vpn_ip_address false, "#{f}"
    ENV["_#{f}_vpn_port"] = consul_get_container_vpn_port($node, "#{f}")
  end


end


def init_node_and_container_dirs
  texec "mkdir -p #{NODE_INFO_DIR}"

  FRAMEWORKS.each do |f|
    texec "mkdir -p #{CONTAINER_DIR}/#{f}"
    save_container_info 'cdh', 'TYPE', f
  end
end

def save_node_info

  init_node_and_container_dirs


  save_container_info ARGV[0], 'HADOOP_IPV4', 'hadoop'

  save_info 0, 'MASTER_IP'
  save_info 1, 'API_IP'
  save_info 2, 'DNS_IP'
  save_info 3, 'CLUSTER_ID'
  save_info 4, 'NODE_ID'
  save_info 5, 'NODE_UID'
  save_info 6, 'CLUSTER_UID'
  save_info 7, 'OPENVPN_IP'
  save_info 8, 'OPENVPN_PORT'
  save_info 9, 'VPN_CLIENT_IP'
  save_info 10, 'VPN_SERVER_IP'
  save_info 11, 'VPN_SERVER_PORT'
  save_info 12, 'SOCKS_PROXY_IP'
  save_info 13, 'STATIC_IPS'
  save_general_info ENV['_interface'], 'HOST_INTERFACE'
  save_general_info 'true', 'HADOOP_SLAVE'


  if ARGV[13] == 'true'

    File.write(File.join(NODE_INFO_DIR, 'CONTAINER_IPS'), ARGV[14])
    save_info 15, 'NETWORK_MASK'
    save_info 16, 'GATEWAY_IP'

    cips = JSON.parse(ARGV[14])

    FRAMEWORKS.each do |f|
      ip = cips[f]
      save_container_info ip, 'CONTAINER_IP', f unless ip.nil?
    end

  end

end


def setup_framework(f)

  use_container f

  save_container_info ENV["_#{f}_overlay_ip"], 'OVERLAY_IP', f

  if ARGV[13] == 'true'
    ENV["_#{f}_container_ip"] = get_container_info('CONTAINER_IP', f) #File.read("#{container_files_dir}/#{f}/CONTAINER_IP").strip
  end
  host_records = []

  FRAMEWORKS.each do |ff|

    unless f == ff

      ip = ENV["_#{ff}_overlay_ip"]
      assert_ip ip
      host_records.push(
          {ip: ip, domain_name: "#{ff}-#{get_node}.gex",
           aliases: "#{ff}-#{get_node}"})

    end

  end

  master_name = "hadoop-master-#{get_info("CLUSTER_ID")}"
  host_records.push(
      {ip: get_info("MASTER_IP"), domain_name: "#{master_name}.gex",
       aliases: master_name}
  )

  gex_create_slave_container "gex/#{f}_#{get_container_info('TYPE', 'hadoop')}", '/etc/bootstrap.sh', ENV["_#{f}_overlay_ip"], host_records: host_records, volumes: VOLUMES

  create_init_lock

  set_container_vars

  processor = ERBProcessor.new(get_vars)

  setup_container_service_and_vpn

  gexcloud_pull_and_process_git_template_trees "#{f}/slave", processor, $container

  remove_init_lock

end


def test_socks_proxy(ip)

  lines = File.readlines '/etc/openvpn/config/password'

  assert_nnil lines, ip

  username = lines[0].strip
  password = lines[1].strip

  cmd = "timeout 1 curl --socks5 http://#{username}:#{password}@#{ip} 127.0.0.1"

  # noinspection RubyUnusedLocalVariable,RubyUnusedLocalVariable
  stdout, stderr, status = Open3.capture3(cmd)

  if stderr.include? 'rejected'
    throw Exception.new "User #{username} could not authenticate to the proxy server #{ip}"
  end


end


def wait_until_network_ok(cluster_id)
  # wait until VPN is ready
  count = 0
  until (texec 'ip route').include? 'dev tun0'
    count = count + 1
    sleep 1
    assert (count < 10), 'Could not connect to GEX VPN server'
  end

  proxy_ip = ENV['_socks_proxy_ip']

  if proxy_ip.include? '.'
    is_port_open?(proxy_ip, '80')
    test_socks_proxy(proxy_ip)
  end

  is_port_open?('51.0.1.8', 22)

  is_port_open?('51.0.1.8', consul_ports(cluster_id)[:http])

  is_port_open?(get_framework_master_ip(cluster_id, 'hadoop'), 22)

  is_port_open?(ENV['_sensu_rabbitmq_host'], 22)

end


safe_exec do

  texec 'echo Starting slaveplaybook.rb'

  exit(0) if provisioned?


  use_node(get_info('NODE_NAME'))


  save_node_info

  init_vars

  FRAMEWORKS.each do |f|
    use_container f
    init_container_dir
  end

  require_relative '../update_scripts/sensu_gemfile'

  setup_environment


  FRAMEWORKS.each do |f|
    echo_append("#{ENV["_#{f}_ipv4"]} #{f}-master-#{ENV['_cluster_id']}", '/etc/hosts')
  end


  wait_until_network_ok("#{ENV['_cluster_id']}")


  add_var('_cluster_name', "#{ENV['_cluster_name']}")

  restart_service 'sensu-client'

  consul_connect(get_value('_cluster_id'))

  node_data = consul_get_node_data(get_value('_node_id'))

  unless node_data['hadoop_app_id']
    texecs('/usr/sbin/avahi-daemon -r', 'echo Completed slaveplaybook.rb')
    set_provisioned
    exit 0
  end


  FRAMEWORKS.each do |f|
    setup_framework f
  end


  texecs \
 '/usr/sbin/avahi-daemon -r',
 'echo Completed slaveplaybook.rb'
  set_provisioned
end




#! /usr/bin/env ruby 
#  encoding: UTF-8
# $Id$


require 'socket'
require 'timeout'

require_relative 'common'
require_relative 'container_service'


def provision_container
  dcp $settings[:json_file_path], '/opt/gex/config/'
  dexec "bash -c 'sh /opt/gex/configure.sh'"
end


def download_container_app_hub(parsed)
  download_link = parsed['download_link']
  assert_nnil download_link
  f = "/tmp/#{$container}.tar.gz"
  texecs \
     "rm -f #{f}",
     "wget -O #{f} #{download_link}"
  return f
end


cname = ARGV[0]
cname = cname.downcase

json_file = ARGV[1] # relative path, applications/$app/config.json

assert_nnil cname, json_file


init_vars

use_container cname
use_node(get_info('NODE_NAME'))


add_var('_dns_ip', get_info('DNS_IP'))
add_var('_cluster_id', get_info('CLUSTER_ID'))
#add_var('_cluster_name', get_info('CLUSTER_NAME'))
add_var('_node_id', get_info('NODE_ID'))
add_var('_openvpn_ip_address', get_info('OPENVPN_IP'))
add_var('_socks_proxy_ip', get_info('SOCKS_PROXY_IP'))
add_var('_master_ip', get_info('MASTER_IP'))

add_var('consul_host', '51.0.1.8')
add_var('consul_port', consul_ports(get_info('CLUSTER_ID'))[:http])


bare_metal? ? json_dir = BARE_METAL_VAGRANT : json_dir = '/vagrant/'

$settings = {
    cname: cname,
    json_file: json_file,
    #node_port: node_port.to_i,
    json_file_path: File.join(json_dir, json_file)
}

assert_file $settings[:json_file_path]

parsed = JSON.parse(File.read($settings[:json_file_path]))

is_apphub = !(parsed['launch_options'].nil?)

#establish_zookeeper_connection
consul_connect(get_info('CLUSTER_ID'))

host_records = []

node_data = consul_get_node_data(get_info('NODE_ID'))

if node_data['hadoop_app_id']

  FRAMEWORKS.each do |ff|
    ip = get_vpn_ip_address(true, ff)
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


init_container_dir

if is_apphub

  full_path = download_container_app_hub(parsed)

  import_options = parsed['launch_options']

  install_container(full_path, image_name: $container, import_options: import_options)

  ## TODO gex_create_slave_container "gex/#{$container}", '', get_vpn_ip_address(true), options: ' -p 80:80 -P '

  gex_create_slave_container "#{$container}", '', get_vpn_ip_address(true), host_records: host_records, options: ""

  #FORWARDS: ' -p 80:80 -P '

  dstart

  add_vars(parsed)
  add_var "_slave_ip", get_vpn_ip_address(true, 'hadoop')
  add_var "_master_ip", get_info("MASTER_IP")


else

  #TODO
  gex_create_slave_container "gex/#{$container}", '/etc/bootstrap', get_vpn_ip_address(true), host_records: host_records


  git_templates_exist = false
  templates_exist = false

  begin
    pull
    templates_path = File.join(GIT_DIR, $container, 'slave/templates')
    git_templates_exist = Dir.exist?(templates_path)
  rescue
    "Couldn't pull from github, continuing"
  end

  begin
    dirname = pull_from_container '/templates/create'
    templates_exist = true
  rescue
    puts 'Cannot pull templates, continuing'
  end

  add_vars(parsed)

  if node_data['hadoop_app_id']
    add_var('_slave_ip', get_vpn_ip_address(true, 'hadoop'))
  end


  add_var('_master_ip', get_info("MASTER_IP"))


  if git_templates_exist
    #processor = ERBProcessor.new(get_vars)
    #gexcloud_pull_and_process_git_template_trees("#{$container}/slave", processor, $container)

    provision_and_start_created_container([templates_path])
  else
    if templates_exist
      provision_and_start_created_container([dirname])
    else
      dstart
      wait_until_running
      provision_container
    end
  end


  #begin
  #  processor = ERBProcessor.new(get_vars)
  #  gexcloud_pull_and_process_git_template_trees "#{$container}/slave", processor, $container
  #rescue
  #  puts 'Cannot pull templates, continuing'
  #end

end

set_container_vars(is_apphub)


setup_container_service_and_vpn(is_apphub)


#`sleep 60`

#dcp "/home/vagrant/ruby_scripts/create_data.sh", "/tmp/create_data.sh"
#dexec "apt-get install -y sudo"
#texec "docker exec -t rocana chmod a+x /tmp/create_data.sh"
#texec "docker exec -u rocana -t rocana bash -c /tmp/create_data.sh"


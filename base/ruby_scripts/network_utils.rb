require 'socket'
require 'timeout'


def add_to_container_hosts(ip, hostnames)
  append_file_with_lines "#{container_hosts}", "#{ip} #{hostnames}"
end


def add_to_hosts(ip, hostnames)
  append_file_with_lines '/etc/hosts', "#{ip} #{hostnames}"
end

def reload_avahi
  texec '/usr/sbin/avahi-daemon -r'
end

def add_contaner_to_avahi(ip)
  append_file_with_lines '/etc/avahi/hosts', "#{ip} #{$container}.local"
  reload_avahi
end


def remove_contaner_from_avahi
  delete_string_matches '/etc/avahi/hosts', "#{$container}"
  reload_avahi
end


def is_port_open?(ip, port, milliseconds = 5000)
  (1..(milliseconds / 100)).each do
    puts "Checking open port #{ip}:#{port}"
    Timeout::timeout(10) do
      begin
        s = TCPSocket.new(ip, port)
        s.close
        return true
      rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
        sleep 0.1
      end
    end
  end
  return false
end

def get_vpn_ip_address(is_client, container = nil)
  if container.nil?
    container = $container
  end
  assert_nnil $container, get_node
  if is_client
    ip = consul_get_container_ip(get_node, container)
  else
    ip = consul_get_container_tunnel_ip(get_node, container)
  end
  assert_ip ip
end

def get_framework_master_ip(cluster_id, f)
  assert_nnil cluster_id, f
  prefix = NETWORK_PREFIXES[f]
  assert_nnil prefix

  "51.#{prefix}." + (cluster_id.to_i / 256).to_s + '.' + (cluster_id.to_i % 256).to_s
end


def reload_nginx
  xexec "/opt/openresty/nginx/sbin/nginx -s reload -c /opt/openresty/nginx/conf/nginx.conf", "gex-webproxy"
end

def hosts_record(ip, name)
  "#{ip} #{name}.gex #{name} "
end


def remove_dnsmasq_entries_by_wildcard(wildcard)
  file = FileEdit.new(container_hosts)
  file.search_file_delete_line wildcard
  file.write_file
  texec "docker exec -t #{$container}  service dnsmasq restart", false
end


def remove_tunnels_by_wildcard(wildcard, container)
  remove_services_by_wildcard "openvpn_#{wildcard}"
  remove_files_by_wildcard "#{container_files_dir}/etc/openvpn/config/#{wildcard}"
  remove_files_by_wildcard "/mount/ansibledata/#{wildcard}"
end

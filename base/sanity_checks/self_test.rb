#!/usr/bin/ruby

def shell(command)
  puts command
  if system(command)
    return 0
  end
  return 1
end


def ping(ip)
  return shell("ping -c 1 #{ip}")
end

def port_ping(ip, port)
  return shell("nc -w 5 -vz #{ip} #{port.to_s}")
end


def get_server_ip(name)
  if File.exist? "/etc/node/nodeinfo/#{name}_IP"
    puts File.read ('/etc/node/nodeinfo/SOCKS_PROXY_IP').strip
    return File.read ('/etc/node/nodeinfo/SOCKS_PROXY_IP').strip

  else
    return nil
  end
end

def run_check(name, description, error_code)

  if error_code == 0
    return
  end
  puts "#!##{name}#!# #{description}\n Please try later, the server may is down for maintenance. "
  exit error_code
end


def ping_server(name)
  server_ip = get_server_ip(name)
  if server_ip == nil
    return 0
  end
  return ping(server_ip)
end


def ping_server_port(name, port)
  server_ip = get_server_ip(name)
  if server_ip == nil
    return 0
  end
  return port_ping server_ip, port
end


run_check "HOST_UNREACHABLE", "Could not ping 8.8.8.8", ping("8.8.8.8")
run_check "HOST_UNREACHABLE", "Could not ping openvpn", ping_server("OPENVPN")
run_check "HOST_UNREACHABLE", "Could not ping socks proxy", ping_server("SOCKS_PROXY")
run_check "PORT_UNREACHABLE", "Could not ping socks proxy port", ping_server_port("SOCKS_PROXY", 80)








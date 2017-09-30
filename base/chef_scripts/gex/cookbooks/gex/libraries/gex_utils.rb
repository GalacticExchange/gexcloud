
class GexUtils
  OPENVPN_HOST = '51.0.1.8'

  def self.docker_bare_metal?
    File.exist?('/home/vagrant/bare_metal_docker')
  end

  def self.wait_for_vpn
    puts
    retries = 0
    while !host_reachable?(OPENVPN_HOST) && retries < 10
      retries += 1
      sleep 2
    end
    host_reachable?(OPENVPN_HOST)
  end

  def self.host_reachable?(host)
    check = Net::Ping::External.new(host)
    res = check.ping?
    if res
      puts "#{host} IS REACHABLE".green
    else
      puts "#{host} IS NOT REACHABLE".yellow
    end
    res
  end

  def self.static_ip(app_name)

  end

  def self.get_app_ifname(app_name)
    #`docker exec -t #{app_name} bash -c ''`
    'eth1'
  end

end

#p GexUtils.wait_for_vpn
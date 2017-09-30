#! /usr/bin/env ruby

require 'json'


container = ARGV[0]
static_ip = ARGV[1]

params = JSON.parse(File.read('/etc/node_data/node.json'))

if params['node_type'] == 'virtualbox'
  ifname = 'enp0s8' # Ubuntu 16 vagrant second interface
  #ifname="eth1"
else
  ifname = `route |grep default |awk '{print $8}'`.strip
end

system("/usr/bin/docker stop #{container} | true")

=begin
d_start = fork do
  exec "nohup /usr/bin/docker start -a #{container} 1> /dev/null 2>/dev/null &"
end
File.write("/tmp/gex_#{container}.pid", d_start.inspect)
Process.detach(d_start)
=end

cmd = <<-EOT
    nohup /usr/bin/docker start -a #{container} 1> /dev/null 2>/dev/null &
    echo $! > /tmp/gex_#{container}.pid
EOT

system(cmd)

unless params['node_type'] == 'aws'
  puts 'NOT AWS'
  if static_ip
    system(%Q(/usr/local/bin/pipework #{ifname} -i eth1 #{container} "#{static_ip}/#{params['network_mask']}@#{params['gateway_ip']}"`))
  else
    system(%Q(/usr/local/bin/pipework #{ifname} -i eth1 #{container} udhcpc))
  end

end

unless File.read('/etc/avahi/hosts').include?(container)
  system(%Q(sed -i.bak "/#{container}/d"  /etc/avahi/hosts`))
  system(%Q(rm /etc/avahi/hosts.bak))
end

system(%Q(rm /etc/node/nodeinfo/#{container}-CONTAINER_IP |true))

if params['node_type'] == 'aws'
  puts 'CLOUD AWS TYPE'
  container_ip = `docker exec #{container} ip addr  |grep "global ethwe" | awk -F'[/\t\n ]' '{print $6}'`.strip
  while container_ip.empty?
    sleep 5
    container_ip = `docker exec #{container} ip addr  |grep "global ethwe" | awk -F'[/\t\n ]' '{print $6}'`.strip
  end
else
  puts 'NON-CLOUD TYPE'
  container_ip =  `docker exec #{container} ip addr  |grep "global eth1" | awk -F'[/\t\n ]' '{print $6}'`
end

File.write("/etc/node/nodeinfo/#{container}-CONTAINER_IP", container_ip)

hostname = `docker exec "#{container}" hostname`
`echo "#{container_ip} #{hostname}.local" >> /etc/avahi/hosts`

if container.start_with?('h')
  puts 'Distributed'
else
  if File.read('/etc/hosts').include?(hostname)
    `sed -i "s/#{hostname}/#{container_ip} #{hostname})/g" /etc/hosts`
  else
    `echo "#{container_ip} #{hostname}" >> /etc/hosts`
  end
end

system(%Q(curl --data "format=json&clusterID=#{params['cluster_id']}&nodeID=#{params['node_id']}&domain=#{hostname}.gex&ip=#{container_ip}" http://#{params['api_ip']}/serviceIp))
system(%Q(/usr/sbin/avahi-daemon -r))
puts 'Runslavedocker completed successfully'






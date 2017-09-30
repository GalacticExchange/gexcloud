#!/usr/bin/env ruby

ENV['_destination_host']=ARGV[0]
ENV['_destination_port']=ARGV[1]
ENV['_source_port']=ARGV[2]

variables = %w{_source_port _destination_host _destination_port}

missing = variables.find_all { |v| ENV[v] == nil }
unless missing.empty?
  raise Exception.new("The following variables are missing and are needed to run this script: #{missing.join(', ')}.")
end

ENV['_proxy_private_ip'] = `ip addr  |grep "global weave" | awk -F'[/\t\n ]' '{print $6}'`
ENV['_proxy_public_ip'] = `ip addr  |grep "global eth0" | awk -F'[/\t\n ]' '{print $6}'`


`j2 /home/vagrant/templates/proxy.service.j2 > /etc/systemd/system/port_#{ENV['_source_port']}.service`
`systemctl enable port_#{ENV['_source_port']}`
`systemctl start port_#{ENV['_source_port']}`
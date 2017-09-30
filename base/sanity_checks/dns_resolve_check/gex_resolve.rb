#!/usr/bin/env ruby

module GexResolve

  HOSTS_PATH = '/etc/hosts'

  BASIC_HOSTNAMES = [
      'api.galacticexchange.io',
      'rabbit.galacticexchange.io',
      'proxy.galacticexchange.io',
      "webproxy.galacticexchange.io",
      'hub.galacticexchange.io'
  ]

  def resolve_basic
    gex_hosts = {}
    BASIC_HOSTNAMES.each do |hostname|
      ip = resolve_host(hostname)
      if ip != 'none'
        gex_hosts[hostname] = ip
      end
    end
    gex_hosts
  end

  def update_hosts
    gex_hosts = resolve_basic
    gex_hosts.map { |key, value| replace_line(key, value, HOSTS_PATH) }
  end

  def resolve_host(hostname)
    result = `host #{hostname} |head -1`
    result.include?("not found") ? 'none' : result.split(' ')[3]
  end

  def replace_line(hostname, ip, file)
    command = %Q(grep -q "#{hostname}" #{file} &&
   sed -i '/<#{hostname}>/c\\#{ip} #{hostname}' #{file} ||
   sed "$ a\\#{ip} #{hostname}" -i #{file})
    system(command)
  end

  module_function :update_hosts, :resolve_basic, :resolve_host, :replace_line
end



#puts GexResolve.update_hosts

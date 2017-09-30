#! /usr/bin/env ruby
#
#   check-container
#
# DESCRIPTION:
#   This is a simple check script for Sensu to check that a Docker container is
#   running. You can pass in either a container id or a container name.
#
# OUTPUT:
#   plain text
#
# PLATFORMS:
#   Linux
#
# DEPENDENCIES:
#   gem: sensu-plugin
#
# USAGE:
#   check-docker-container.rb c92d402a5d14
#   CheckDockerContainer OK
#
#   check-docker-container.rb circle_burglar
#   CheckDockerContainer CRITICAL: circle_burglar is not running on the host
#
# NOTES:
#     => State.running == true   -> OK
#     => State.running == false  -> CRITICAL
#     => Not Found               -> CRITICAL
#     => Can't connect to Docker -> WARNING
#     => Other exception         -> WARNING
#
# LICENSE:
#   Copyright 2014 Sonian, Inc. and contributors. <support@sensuapp.org>
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.
#

require 'sensu-plugin/metric/cli'
require 'sensu-plugins-docker/client_helpers'
require 'json'
require 'faraday'
require 'timeout'

#
# Check Docker Container
#
class CheckDockerContainer < Sensu::Plugin::Metric::CLI::Graphite
  option :docker_host,
         short: '-h DOCKER_HOST',
         long: '--host DOCKER_HOST',
         description: 'Docker socket to connect. TCP: "host:port" or Unix: "/path/to/docker.sock" (default: "127.0.0.1:2375")',
         default: '127.0.0.1:2375'
  #option :container,
  #       short: '-c CONTAINER',
  #       long: '--container CONTAINER',
  #       required: true
  #option :tag,
  #       short: '-t TAG',
  #       long: '--tag TAG'
  def run
    client = create_docker_client
    path = "/containers/json"
    req = Net::HTTP::Get.new path
    begin
      response = client.request(req)
      body = JSON.parse(response.body)

      containers = {}

      body.each do |container|
        container_name = container['Names'].first.gsub('/','')
        container_state = container['State']
        container_status = container['Status']

        containers[container_name] = {state: container_state, status: container_status}
      end

      # data from consul
      cluster_id = get_node_prop_value('CLUSTER_ID')
      node_id = get_node_prop_value('NODE_ID')
      node_data = get_node_data(cluster_id, node_id)

      #puts "node data: #{node_data}"
      #exit 1

      # services in hadoop container
      containers['hadoop'] ||= {}
      containers['hadoop']['services'] = {}

      # get container ip
      container_ip = get_container_ip('hadoop', node_data)
      #container_ip = "51.128.24.177"

      # check servcies only if container is running
      if containers['hadoop'] && containers['hadoop'][:state] =='running'

        containers['hadoop']['services']['elasticsearch'] = get_status_elasticsearch(container_ip)
        containers['hadoop']['services']['kibana'] = get_status_kibana(container_ip)
      end

      ### services in hue container
      containers['hue'] ||= {}
      containers['hue']['services'] = {}


      container_ip = get_container_ip('hue', node_data)
      #container_ip = "51.128.24.179"

      if containers['hue'] && containers['hue'][:state] =='running'
        containers['hue']['services']['hue'] = get_status_hue(container_ip)
      end





      # result
      output containers.to_json.to_s
      ok


    rescue JSON::ParserError => e
      critical "JSON Error: #{e.inspect}"
    rescue => e
      warning "Error: #{e.inspect}"
    end
  end


  def get_node_data(cluster_id, node_id)
    key = "nodes/id/#{node_id}/node_data.json"
    v = consul_get(cluster_id, key)

  end


  def get_container_ip(container_name, node_data)
    key = "nodes/#{node_data['name']}/containers/#{container_name}/primary_ip"
    consul_get_val(node_data['cluster_id'], key)
  end


  def get_node_prop_value(prop_name)
    f = "/etc/node/nodeinfo/#{prop_name}"
    s = IO.read(f)
    s = s.strip

    s
  end

  ###
  def consul_ports(cluster_id)
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


  ### consul
  def consul_get(cluster_id, key_data)
    u = consul_url(cluster_id)
    key = "/v1/kv/#{key_data}"

    conn = Faraday.new(:url => u)

    response = conn.get "#{key}?raw"

    v = JSON.parse(response.body) rescue nil

    return v
  rescue => e
    return nil
  end


  def consul_get_val(cluster_id, k, v_def=nil)
    u = consul_url(cluster_id)
    key = "/v1/kv/#{k}"

    conn = Faraday.new(:url => u)

    response = conn.get "#{key}?raw"
    v = response.body rescue nil

    return v
  rescue => e
    v = v_def

    return v
  end

  def consul_url(cluster_id)
    port = consul_ports(cluster_id)[:http]
    u = "http://51.0.1.8:#{port}"
  end


  ### hue
  def get_status_hue(container_ip)
    res_service = {}


    # port
    res_service['port'] = get_status_port(container_ip, 8000)

=begin
    # response
    res = {res: false, output: ''}

    need_check_response = res_service['port'][:res]
    if need_check_response

      begin
        res[:output] = get_curl("http://#{container_ip}:9200/_cluster/health")
        output_data = JSON.parse(res[:output])

        res[:res] = output_data["status"]=="yellow"
      rescue => e
        res[:res] = false
      end

      res_service['response'] = res
    end
=end

    #
    res_service
  end



  ### elasticsearch

  def get_status_elasticsearch(container_ip)
    res_service = {}


    # port
    res_service['port'] = get_status_port(container_ip, 9200)

    # response
    res = {res: false, output: ''}

    need_check_response = res_service['port'][:res]
    if need_check_response

      begin
        res[:output] = get_curl("http://#{container_ip}:9200/_cluster/health")
        output_data = JSON.parse(res[:output])

        res[:res] = output_data["status"]=="yellow"
      rescue => e
        res[:res] = false
      end

      res_service['response'] = res
    end


    #
    res_service
  end



  ### kibana

  def get_status_kibana(container_ip)
    res_service = {}


    # port
    res_service['port'] = get_status_port(container_ip, 5601)

=begin
    # response
    res = {res: false, output: ''}

    need_check_response = res_service['port'][:res]
    if need_check_response

      begin
        res[:output] = get_curl("http://#{container_ip}:9200/_cluster/health")
        output_data = JSON.parse(res[:output])

        res[:res] = output_data["status"]=="yellow"
      rescue => e
        res[:res] = false
      end

      res_service['response'] = res
    end
=end


    #
    res_service
  end



  ### status - helpers

  def get_status_port(ip, port)
    res = {res: false, port: port}

    begin

      #
      output = `nc -w2 -zv #{ip} #{port} 2>&1`
      exit_code = $?.exitstatus
      #$?.success?

      res[:res] = exit_code==0
      res[:output] = output
    rescue => e
      res[:res] = false

    end


    #
    res
  end



  ### common
  def get_curl(url, t=1)
    begin
      Timeout::timeout(t) do
        output = `curl -X GET #{url}  2>/dev/null`

        return output
      end
    rescue => e
      return "error"
    end
  end



end

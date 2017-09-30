#! /usr/bin/env ruby
#  encoding: UTF-8
#  rabbitmq_handler.rb
#
# DESCRIPTION:
#   This handler formats messages and store them in RabbMQ
#
# OUTPUT:
#   Delivers message to RabbitMQ.
#
# PLATFORMS:
#   All
#
# DEPENDENCIES:
#   gem: sensu-plugin
#   gem: bunny
#
# USAGE:
#
# LICENSE:
#   Max Ivak maxivak@gmail.com
#   Released under the same terms as Sensu (the MIT license); 
#   see LICENSE for details.


require 'sensu-handler'
require 'bunny'
require 'timeout'


class RabbitmqHandler < Sensu::Handler
  def short_name
    @event['client']['name'] + '/' + @event['check']['name']
  end

  def action_to_string
    @event['action'].eql?('resolve') ? 'RESOLVED' : 'ALERT'
  end

  def handle

    begin
      timeout 10 do
        # debug
        #file_name = "/etc/sensu/debug_#{@event['client']['name']}_#{@event['check']['name']}.json"
        #File.open(file_name, 'a+') do |file|
        #sd = @event['check']['executed']
        #d = Time.at(sd.to_i).utc.to_datetime

        #file.write("#{d} --")
        #file.write(JSON.pretty_generate(@event['check']))

        #file.write(JSON.pretty_generate(settings))
        #end


        # send to rabbitmq
        conn = Bunny.new(
            :hostname => settings['rabbitmq']['host'],
            :vhost => settings['rabbitmq']['vhost'],
            :user => settings['rabbitmq']['user'],
            :password => settings['rabbitmq']['password']
        )
        conn.start


        ch = conn.create_channel

        # exchange
        # noinspection RubyUnusedLocalVariable
        exchange_name = 'gex.nodes.checks'
        exchange = ch.topic('gex.nodes.checks', :durable => true, :auto_delete => false)

        #
        node_id = @event['client']['props']['node_id']
        msg_routing_key = "#{node_id}.checks.#{@event['check']['name']}"
        event_data = @event
        exchange.publish(event_data.to_json, :routing_key => msg_routing_key)


        puts 'rabbitmq -- sent for ' + short_name
      end
    rescue Timeout::Error
      puts 'rabbitmq -- timed out while attempting to ' + @event['action'] + ' an incident -- ' + short_name

    end
  end
end

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
#   gem: ruby-kafka
#
# USAGE:
#
# LICENSE:
#   Max Ivak maxivak@gmail.com
#   Released under the same terms as Sensu (the MIT license); 
#   see LICENSE for details.


require 'sensu-handler'
require "kafka"
require 'timeout'


class KafkaHandler < Sensu::Handler
  def short_name
    @event['client']['name'] + '/' + @event['check']['name']
  end

  def action_to_string
    @event['action'].eql?('resolve') ? 'RESOLVED' : 'ALERT'
  end

  def handle

    begin
      # remove some fields
      %w(history subscribers handlers command).each do |f|
        @event['check'][f] = nil
      end


      timeout 10 do

        # debug
        file_name = "/etc/sensu/debug_#{@event['client']['name']}_#{@event['check']['name']}.json"
        File.open(file_name, 'a+') do |file|
          sd = @event['check']['executed']
          #d = Time.at(sd.to_i).utc.to_datetime
          d = Time.at(sd.to_i)

          file.write("#{d} --")

          file.write(JSON.pretty_generate(@event['check']))
          #file.write(JSON.pretty_generate(settings))
        end


        # send to kafka
        kafka = Kafka.new(
            seed_brokers: [settings['kafka']['broker']],

            # Set an optional client id in order to identify the client to Kafka:
            client_id: "sensu_handler",
        )


        #
        node_id = @event['client']['props']['node_id']
        # noinspection RubyUnusedLocalVariable
        msg_routing_key = "#{node_id}.checks.#{@event['check']['name']}"
        event_data = @event['check']
        #exchange.publish(event_data.to_json, :routing_key => msg_routing_key)

        # publish to kafka
        #topic = 'gex.nodes.checks'
        topic = "gex.#{node_id}.checks.#{@event['check']['name']}"
        kafka.deliver_message(event_data.to_json, topic: topic, key: @event['check']['executed'].to_s)

        puts 'kafka -- sent for ' + short_name
      end
    rescue Timeout::Error
      puts 'kafka -- timed out while attempting to ' + @event['action'] + ' an incident -- ' + short_name

    end
  end
end

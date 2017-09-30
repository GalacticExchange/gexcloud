#! /usr/bin/env ruby
#  encoding: UTF-8
#  rabbitmq_handler.rb
#
# DESCRIPTION:
#   This handler formats messages and store them in Redis
#
# OUTPUT:
#   Delivers message to Redis.
#
# PLATFORMS:
#   All
#
# DEPENDENCIES:
#   gem: sensu-plugin
#   gem: redis
#
# USAGE:
#
# LICENSE:
#   Max Ivak maxivak@gmail.com
#   Released under the same terms as Sensu (the MIT license);
#   see LICENSE for details.


require 'sensu-handler'
require 'redis'
require 'timeout'


class RedisHandler < Sensu::Handler
  def short_name
    @event['client']['name'] + '/' + @event['check']['name']
  end

  def action_to_string
    @event['action'].eql?('resolve') ? 'RESOLVED' : 'ALERT'
  end

  def handle

    puts "redis start for #{short_name}"

    begin
      timeout 10 do
        # debug
        #file_name = "/etc/sensu/debug_#{@event['client']['name']}_#{@event['check']['name']}.json"
        #File.open(file_name, 'a+') do |file|
        #sd = @event['check']['executed']
        #d = Time.at(sd.to_i).utc.to_datetime rescue nil

        #file.write("#{d} --")
        #file.write(JSON.pretty_generate(@event['check']))

        #file.write(JSON.pretty_generate(settings))
        #end

        #
        redis_config = settings['redis_counters']
        # add to /etc/sensu/config.json
=begin
        "redis_counters": {
            "host": "api.gex",
            "prefix": "gex"
        },
=end

        redis = Redis.new(:host => redis_config['host'], :port => 6379)

        #
        node_id = @event['client']['props']['node_id']

        #
        key = "#{redis_config['prefix']}.node.#{node_id}.checks.#{@event['check']['name']}"

        #
        redis.set key, @event.to_json
        redis.expire key, 4*60*60

        #
        puts "redis -- set #{key} for #{short_name}"
      end
    rescue Timeout::Error
      puts 'redis -- timed out while attempting to ' + @event['action'] + ' an incident -- ' + short_name
    end
  end
end

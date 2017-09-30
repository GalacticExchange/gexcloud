#! /usr/bin/env ruby
#  encoding: UTF-8
#
#   check_gex_api_events
#
# DESCRIPTION:
#
# OUTPUT:
#   metric data
#
# PLATFORMS:
#   Linux
#
# DEPENDENCIES:
#   gem: sensu-plugin
#
# USAGE:
#
# NOTES:
#
# LICENSE:
#   Copyright 2012 Sonian, Inc <chefs@sonian.net>
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.


require 'sensu-plugin/check/cli'
require 'json'
require 'bunny'


class CheckGexApiEvents < Sensu::Plugin::Check::CLI
=begin
  option :warn,
         :short => '-w WARN',
         :proc => proc {|a| a.to_i },
         :default => 10

  option :crit,
         :short => '-c CRIT',
         :proc => proc {|a| a.to_i },
         :default => 5
=end


  def run
    settings = JSON.parse(File.read("/etc/sensu/conf.d/client.json"))



    # get message from bunny
    rabbitmq_settings = settings['client']['props']['rabbitmq']

    #output "#{rabbitmq_settings.inspect}"

    conn = Bunny.new(
        :hostname => rabbitmq_settings['host'],
        :vhost => rabbitmq_settings['vhost'],
        :user => rabbitmq_settings['user'],
        :password => rabbitmq_settings['password'],
        :continuation_timeout => 15000,
        #:heartbeat => 30,
        :automatically_recover => true,
        :network_recovery_interval => 3,
        :recover_from_connection_close => false,
    )
    conn.start


    ch = conn.create_channel

    # exchange
    x = ch.topic('gex.api_events')
    q = ch.queue('gex.api_events', :auto_delete => false, :exclusive => false, :durable=>false)
    q.bind(x, :routing_key => '#')

    #
    msg = nil
    messages = []
    # noinspection RubyUnusedLocalVariable
    res = false

    #
    begin
      timeout 10 do
        begin
          # noinspection RubyUnusedLocalVariable
          ret = # noinspection RubyUnusedLocalVariable,RubyUnusedLocalVariable
              q.subscribe(:block => true, :timeout=>10) do |delivery_info, metadata, body|
            msg = JSON.parse(body)

            # check msg
            if msg['type']

              # skip
            end

            messages << msg

            #
            #cancel_ok = consumer.cancel
            #ch.consumers[delivery_info.consumer_tag].cancel

          end  # / subscribe

            #q.unsubscribe
        rescue => # noinspection RubyUnusedLocalVariable
        e
          # noinspection RubyUnusedLocalVariable
          res = false
        end

      end # / timeout

    rescue Timeout::Error
      # noinspection RubyUnusedLocalVariable
      res = false

    rescue => # noinspection RubyUnusedLocalVariable
    e
      # noinspection RubyUnusedLocalVariable
      res = false

    end

    begin
      #
      #q.unsubscribe
      ch.close
      conn.close
    rescue => # noinspection RubyUnusedLocalVariable
    e
      # noinspection RubyUnusedLocalVariable
      x = 0
    end


    #
    puts "#{messages.to_json}"

    # exit
    #EXIT_CODES = {        'OK'       => 0,        'WARNING'  => 1,        'CRITICAL' => 2,        'UNKNOWN'  => 3    }

    if messages.nil? || messages.empty?
      # do nothing
      exit(0)
    else
      #output messages.to_json
      exit(1)
    end


    #data = {type: 'debug_error', message: "test msg"}
    #message "#{v}% value"
    #output data.to_json

    #critical if v < config[:crit]
    #warning if v < config[:warn]

    ok
  end
end

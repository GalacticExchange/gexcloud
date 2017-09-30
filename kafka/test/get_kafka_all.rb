#!/usr/bin/env ruby

require 'csv'
require 'json'
require "kafka"
require 'timeout'

#
KAFKA_SERVER = "10.1.0.12"
#KAFKA_SERVER = "localhost"

#TOPIC = "t2"
TOPIC = "logstash"
#TOPIC = "gex.our_mmx.checks.debug_metrics_hdd"
#TOPIC = "gex.our_mmx.checks.metrics_memory"
#TOPIC = "gex.our_mmx.checks.metrics_hdd"
#TOPIC = "__consumer_offsets"
#TOPIC = "gex.1626738196165529.checks.metrics_cpu"

def sh(cmd)
  `#{cmd}`
end

logger = Logger.new("log_kafka.log")

kafka = Kafka.new(
    # At least one of these nodes must be available:
    seed_brokers: ["#{KAFKA_SERVER}:9092"],
    connect_timeout: 30,
    socket_timeout: 20,
    logger: logger,


    # Set an optional client id in order to identify the client to Kafka:
    #client_id: "my-application",
)


begin
  timeout 5 do
    kafka.each_message(topic: TOPIC, start_from_beginning: true, max_wait_time: 0.1) do |message|
      puts "--- offset: #{message.offset}, partition: #{message.partition}, key: #{message.key}"
      puts "data: #{message.value}"

      #break
    end
  end
rescue Timeout::Error
  puts 'kafka -- timed out '

end

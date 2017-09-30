#!/usr/bin/env ruby

require 'csv'
require 'json'
require "kafka"


#
#KAFKA_SERVER = "172.17.0.2"
#KAFKA_SERVER = "localhost"
#KAFKA_SERVER = "51.1.0.50"
KAFKA_SERVER = "10.1.0.12"
TOPIC = "t9"
#TOPIC = "gex.our_mmx.checks.metrics_memory"
#TOPIC = "gex.our_mmx.checks.debug_metrics_docker_stats"
#TOPIC = "gex.our_mmx.checks.debug_metrics_docker_container"

def sh(cmd)
  `#{cmd}`
end

logger = Logger.new(StringIO.new)

kafka = Kafka.new(
    # At least one of these nodes must be available:
    seed_brokers: ["#{KAFKA_SERVER}:9092"],
    connect_timeout: 30,
    socket_timeout: 20,
    logger: logger

    # Set an optional client id in order to identify the client to Kafka:
    #client_id: "my-application",
)


consumer = kafka.consumer(group_id: "my-consumer-3", session_timeout: 30)
trap("TERM") { consumer.stop }


consumer.subscribe(TOPIC, start_from_beginning: true)

#consumer.each_message do |message|
#  puts "--- offset: #{message.offset}, partition: #{message.partition}, key: #{message.key}"
#  puts "data: #{message.value}"
#end



#consumer.each_batch(max_wait_time: 10) do |batch|
consumer.each_batch do |batch|
  puts "=========== Received batch: #{batch.topic}/#{batch.partition}"

  #transaction = index.transaction



  batch.messages.each do |message|
    # Let's assume that adding a document is idempotent.
    #transaction.add(id: message.key, body: message.value)

    puts "--- offset: #{message.offset}, partition: #{message.partition}, key: #{message.key}"
    puts "data: #{message.value}"
  end

  # Once this method returns, the messages have been successfully written to the
  # search index. The consumer will only checkpoint a batch *after* the block
  # has completed without an exception.
  #transaction.commit!
end

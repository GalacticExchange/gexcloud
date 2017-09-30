#!/usr/bin/env ruby

require 'csv'
require 'json'
require "kafka"


#
#KAFKA_SERVER = "172.17.0.3"
KAFKA_SERVER = "10.1.0.12"
#KAFKA_SERVER = "51.1.0.50"
#TOPIC = "t2"
TOPIC = "logstash"

def sh(cmd)
  `#{cmd}`
end

#sh 'touch /tmp/test_api.txt'

s = File.read('temp.json')
d = JSON.parse(s)

#
dnow = Time.now
n = rand(10000)

d["n"] = n
d["date"] = dnow


# output
#puts "#{d.to_json}"

kafka = Kafka.new(
    # At least one of these nodes must be available:
    seed_brokers: ["#{KAFKA_SERVER}:9092"],

    # Set an optional client id in order to identify the client to Kafka:
    #client_id: "my-application",
)

kafka.deliver_message("#{d.to_json}", topic: TOPIC)
#kafka.deliver_message("#{d.to_json}", topic: TOPIC, key: "node_id_1")

# All messages with the same `session_id` will be assigned to the same partition.
#producer.produce(event, topic: "user-events", partition_key: session_id)

#partitions = kafka.partitions_for("events")

=begin
kafka.each_message(topic: "elvistest") do |message|
  puts message.value
end
=end

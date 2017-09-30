#!/usr/bin/env ruby
require_relative 'coordinator_ami'
require_relative 'node_ami'

#TODO fix output

coordinator_thread = Thread.new {
  cluster_coord = CoordinatorAmi.new(
      aws_access_key: ENV['AWS_ACCESS_KEY_ID'],
      aws_secret_key: ENV['AWS_SECRET_KEY'],
      key_path: ENV['PEM_FILE_PATH']
  )
  cluster_coord.start
  cluster_coord.run_install
  cluster_coord.create_counter
  cluster_coord.create_amis
}
#node_plain_thread = Thread.new{
#  clusterGX_node = NodeAmi.new(ENV['AWS_ACCESS_KEY_ID'], ENV['AWS_SECRET_KEY'], ENV['PEM_FILE_PATH'])
#  clusterGX_node.start
#  clusterGX_node.run_install
#  clusterGX_node.set_hadoop_type('plain')
#  clusterGX_node.speed_up
#  clusterGX_node.create_ami
#}

node_cdh_thread_main = Thread.new {
  node = NodeAmi.new(
      aws_access_key: ENV['AWS_ACCESS_KEY_ID'],
      aws_secret_key: ENV['AWS_SECRET_KEY'],
      key_path: ENV['PEM_FILE_PATH'],
      gex_env: 'main'
  )
  node.set_hadoop_type('cdh')
  node.start
  node.run_install
  node.speed_up
  node.create_amis
}


node_cdh_thread_prod = Thread.new {
  node = NodeAmi.new(
      aws_access_key: ENV['AWS_ACCESS_KEY_ID'],
      aws_secret_key: ENV['AWS_SECRET_KEY'],
      key_path: ENV['PEM_FILE_PATH'],
      gex_env: 'prod'
  )
  node.set_hadoop_type('cdh')
  node.start
  node.run_install
  node.speed_up
  node.create_amis
}


coordinator_thread.join
node_cdh_thread_main.join
#node_plain_thread.join

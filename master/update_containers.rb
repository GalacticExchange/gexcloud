#!/usr/bin/env ruby
require "rake"

tag = Time.now.to_i.to_s
sh "docker import /disk2/hue_cdh.tar gex/hue_cdh:#{tag}"
sh "docker import /disk2/hadoop_cdh_master.tar gex/hadoop_cdh:#{tag}"
sh "docker tag  gex/hadoop_cdh:#{tag} gex/hadoop_cdh:latest"
sh "docker tag  gex/hue_cdh:#{tag} gex/hue_cdh:latest"
sh 'bash -c "docker images -q |xargs docker rmi | true"'

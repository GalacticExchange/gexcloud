#! /usr/bin/env ruby 
#  encoding: UTF-8

#require "tracer"

puts `bash -c "cd #{ARGV[0]}; vagrant up #{ARGV[1]}"`
while true
  sleep 10
  status = `bash -c "cd #{ARGV[0]}; vagrant status #{ARGV[1]}"`
  puts status
  puts  !(status =~ /(.*)running(.*)/)
  abort unless status =~ /(.*)running(.*)/
end

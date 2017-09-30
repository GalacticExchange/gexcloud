#! /usr/bin/env ruby 
#  encoding: UTF-8

#require "tracer"

puts `bash -c "cd #{ARGV[0]}; vagrant halt #{ARGV[1]}"`

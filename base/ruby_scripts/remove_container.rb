#! /usr/bin/env ruby 
#  encoding: UTF-8
# $Id$

require_relative 'common'
require_relative 'container_service.rb'

init_vars

cname = ARGV[0]
cname = cname.downcase

#Done

ENV['_app_name'] = cname

$settings = {
    cname: cname,
}


use_container cname
use_node get_info('NODE_NAME')

disable_and_stop_container_service

drm





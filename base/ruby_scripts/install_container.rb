#! /usr/bin/env ruby 
#  encoding: UTF-8
# $Id$
require 'pathname'

require_relative 'common'

file_path = ARGV[0]
cname = ARGV[1]

init_vars

use_container cname

use_node(get_info('NODE_NAME'))

file_path = File.join(BARE_METAL_VAGRANT, file_path) if bare_metal?

if file_path.to_s.empty? || !(Pathname.new(file_path)).absolute?
  throw Exception.new "Invalid container file name #{file_path}"
end

install_container(file_path, image_name:  "gex/" + cname)
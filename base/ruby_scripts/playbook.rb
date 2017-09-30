#! /usr/bin/env ruby 
#  encoding: UTF-8
# $Id$

require_relative 'common'


texec('echo Starting playbook.rb')

exit(0) if provisioned?


save_general_info ARGV[0], 'NODE_NAME'


init_vars ({
    '_hostname' => ARGV[0],
    '_node_id' => ARGV[2],
    '_sensu_rabbitmq_user' => ARGV[3],
    '_sensu_rabbitmq_password' => ARGV[4],
    '_sensu_rabbitmq_host' => ARGV[5],
    '_nserver' => ARGV[6],
    '_sensu_name' => ARGV[7]
})


processor = get_processor
processor.process_template_file '/etc/systemd/system/client.json.erb', '/etc/systemd/system', destination: '/etc/sensu/conf.d/client.json'
processor.process_template_file '/etc/systemd/system/config.json.erb', '/etc/systemd/system', destination: '/etc/sensu/config.json'

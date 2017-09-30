#! /usr/bin/env ruby 
#  encoding: UTF-8
# $Id$

require 'fileutils'
require 'slack-notifier'
require 'socket'
require 'parallel'

NODE_INFO_DIR = '/etc/node/nodeinfo'
BARE_METAL_VAGRANT = '/home/vagrant/.gex/node/'
PROVISION_FILE = 'PROVISIONED'
CONTAINER_DIR = '/disk2/containers'
FRAMEWORKS = %w(hadoop hue)
EXCEPTION_URL='https://hooks.slack.com/services/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'

EXCEPTION_URL_MAIN ='https://hooks.slack.com/services/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'
EXCEPTION_URL_PROD ='https://hooks.slack.com/services/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'


NETWORK_PREFIXES = {
    'hadoop' => '77',
    'hue' => '78'
}


begin
  require_relative '../../common/config/config'
rescue Exception => e
# ignored
end


require_relative 'docker_utils'
require_relative 'assert_utils'
require_relative 'exception_utils'
require_relative 'node_utils'
require_relative 'edit_utils'
require_relative 'file_utils'
require_relative 'network_utils'
require_relative 'ansible_utils'
require_relative 'service_utils'
require_relative 'template_utils'
require_relative 'zookeeper_utils' #TODO
require_relative 'consul_utils'
require_relative 'gexcloud_container_utils'

OPENVPN_PACKAGES = [
    {
        os_name: 'ubuntu',
        install_command: 'apt-get -y install openvpn'

    },
    {
        os_name: 'centos',
        install_command: "sh -c 'yum -y install epel-release && yum -y install openvpn && groupadd nogroup'"
    },
    {
        os_name: 'alpine',
        install_command: 'apk add --no-cache openvpn'
    },
    {
        os_name: 'arch linux',
        install_command: 'pacman -Sy --noconfirm openvpn'
    }
]











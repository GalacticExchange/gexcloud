#!/usr/bin/env ruby
require_relative 'node_ami'

clusterGX_node = NodeAmi.new('PH_GEX_KEY_ID', 'PH_GEX_ACESS_KEY','GEXExp.pem')
clusterGX_node.start
clusterGX_node.get_instance.scp_upload('socat/', '/home/ubuntu/', :recursive => true)
clusterGX_node.get_instance.ssh(%Q(mv /home/ubuntu/socat/* /home/ubuntu/))
#clusterGX_node.run_install
#clusterGX_node.create_ami




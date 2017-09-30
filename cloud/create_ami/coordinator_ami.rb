#!/usr/bin/env ruby
require_relative 'gex_aws_ami'


class CoordinatorAmi < GexAWSAmi
  # @fog -> basic fog object
  # @instance_ami_id -> clusterGX coordinator ami id
  # @key_path

  def initialize (params = {})
    @instance_ami_id = UBUNTU_AMI['16.04']
    @image_description = 'coordinator_ami'
    super
  end

  def start
    super
    @fog.tags.create(resource_id: @instance.identity, key: 'Name', value: 'Ami Cluster coordinator')
  end

  def child_hook
    ansible_provision('coordinator.yml')
  end

  def custom_upload
    scp('socat/templates', '/home/vagrant/')
    scp('socat/socat.rb', '/home/vagrant/')
    scp('files/get_ip.rb', '/home/vagrant')
    scp('systemd_services/weave_expose.service', '/home/vagrant/')
  end

  def create_counter
    ssh('touch /home/vagrant/counter')
    ssh('echo 1 > /home/vagrant/counter')
  end

  private :added_packages, :custom_upload


end
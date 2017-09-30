#!/usr/bin/env ruby
require_relative 'gex_aws_ami'


class NodeAmi < GexAWSAmi
  # @instance_ami_id -> clusterGX node ami id
  # @hadoop_type
  attr_reader :hadoop_type

  #def initialize (aws_access_key, aws_secret_key, key_path)
  def initialize (params = {})
    @instance_ami_id = UBUNTU_AMI['16.04']
    @gex_env = params.fetch(:gex_env)
    @image_description = "#{@gex_env}_node_ami"
    super
  end

  def start
    super
    @fog.tags.create(resource_id: @instance.identity, key: 'Name', value: 'Ami Node')
  end


  def custom_upload
    version = Net::HTTP.get(URI('https://d18ms0xu9tssc7.cloudfront.net/gex-baremetal-aws-version.txt')).strip
    version.slice!('version=')
    @instance.ssh(%Q(wget -O /tmp/baremetal.deb https://d18ms0xu9tssc7.cloudfront.net/gex-baremetal-aws_#{version}.deb))
    @instance.ssh(%Q(sudo dpkg -i /tmp/baremetal.deb))
  end

  def set_hadoop_type(hadoop_type)
    @hadoop_type = hadoop_type
    @image_description = "#{@image_description}_#{hadoop_type}"
  end

  def speed_up
    if @hadoop_type.nil?
      raise 'HADOOP TYPE NOT SET'
    end

    @instance.ssh(%Q(cd /home/vagrant/gexstarter/update_containers && rake update_all_containers[#{@hadoop_type}]))

    puts 'running asnible playbooks'

    @instance.ssh(%Q(sudo ansible-playbook -i \"localhost,\" -c local /home/vagrant/ubuntu15docker.yml))
    @instance.ssh(%Q(sudo ansible-playbook -i \"localhost,\" -c local -e "hdp_type=#{@hadoop_type}" /home/vagrant/playbookimage.yml))
  end

  def child_hook

    version = ''
    test = ''
    if @gex_env == 'main'
      version = Net::HTTP.get(URI('https://d18ms0xu9tssc7.cloudfront.net/gex-baremetal-aws-test-version.txt')).strip
      test = '-test'
    else
      version = Net::HTTP.get(URI('https://d18ms0xu9tssc7.cloudfront.net/gex-baremetal-aws-version.txt')).strip
    end

    version.slice!('version=')
    ansible_provision(
        'node.yml',
        version: version,
        test: test,
        hadoop_type: @hadoop_type,
        gexd_repo: GEXD_DEB.fetch(@gex_env.to_sym)[:repo],
        lsb_release: 'xenial',
        gexd_package: GEXD_DEB.fetch(@gex_env.to_sym)[:package]

    )
  end

  private :added_packages, :custom_upload

end
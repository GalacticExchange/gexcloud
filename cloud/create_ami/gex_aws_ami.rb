#!/usr/bin/env ruby
require 'fog'
require 'net/http'

require_relative 'helper'

class GexAWSAmi

  include Helper

  attr_accessor :fog, :instance, :key_path, :instance_ami_id, :image_description

  #def initialize (aws_access_key, aws_secret_key, key_path)
  def initialize (params = {})
    @key_path = params[:key_path]

    @aws_access_key_id = params[:aws_access_key]
    @aws_secret_key = params[:aws_secret_key]

    @fog = Fog::Compute.new(
        :provider => 'AWS',
        :region => DEFAULT_REGION,
        :aws_access_key_id => @aws_access_key_id,
        :aws_secret_access_key => @aws_secret_key
    )

    @storage = Fog::Storage.new(
        :provider => 'AWS',
        :region => 'us-west-1',
        :aws_access_key_id => @aws_access_key_id,
        :aws_secret_access_key => @aws_secret_key
    )

    @ami_version = Time.now.to_i.to_s

    puts @instance_ami_id
    puts @image_description
  end

  def start
    @instance = @fog.servers.create(
        :image_id => @instance_ami_id,
        :flavor_id => 't2.medium',
        :key_name => 'GEXExp',
        :block_device_mapping => [{:DeviceName => '/dev/sda1', 'Ebs.VolumeSize' => 100}]
    )

    @instance.wait_for { print "."; ready? }
    @instance.private_key_path = @key_path
    @instance.username = 'ubuntu'
    check_for
  end

  def check_for
    print "waiting for instance to be totally ready"

    begin
      @instance.ssh(%Q(echo hello world!))
    rescue
      print('.')
      sleep(10)
      retry
    end
    puts
    puts 'READY!'
  end


  def copy_ami(ami_id, region, name)
    fog = get_fog_by_region(region)
    resp = fog.copy_image(ami_id, DEFAULT_REGION, name)
    resp.body['imageId']
  end

  def create_prime_ami
    data = @fog.create_image(@instance.identity, get_ami_name(DEFAULT_REGION), @image_description)
    data.body['imageId']
  end

  def configure_ami(ami_id, region)
    clean_old_ami(region)
    save_ami_id(get_ami_s3_file_name(region), ami_id)
    set_ami_public(ami_id, region)
  end

  def create_amis
    prime_ami_id = create_prime_ami

    configure_ami(prime_ami_id, DEFAULT_REGION)

    ami_threads = []

    AWS_REGIONS.each { |region|

      ami_threads.push(
          Thread.new {
            id = copy_ami(prime_ami_id, region, get_ami_name(region))
            configure_ami(id, region)
          }
      )
    }

    ami_threads.each { |thr| thr.join }

    terminate
  end

  def save_ami_id(filename, ami_id)

    bucket = @storage.directories.get('gex-ami-ids')

    ami_s3_file =bucket.files.create(
        :key => filename,
        :body => ami_id,
        :public => true
    )
    puts 'URL: ' + ami_s3_file.public_url
  end

  def run_install
    puts 'running install'
    install_ansible
    ansible_provision('basic.yml')
    @instance.username = 'vagrant'
    child_hook
    custom_upload
  end

  def child_hook;
  end

  def added_packages;
  end

  def custom_upload;
  end

  def terminate
    @instance.destroy
  end

  def connect_to_instance (instance_aws_id)
    if @instance != nil
      raise Exception.new('This object already has connection to instance')
    end
    @instance = @fog.servers.get(instance_aws_id)
    @instance.private_key_path = @key_path
    @instance.username = 'vagrant'
  end

  def set_ami_public(image_id, region)
    fog = get_fog_by_region(region)
    print 'Waiting ami to come up'
    begin
      fog.modify_image_attribute(image_id, {'Add.Group' => ['all']})
    rescue
      print('.')
      sleep(10)
      retry
    end
    puts
    puts 'READY!'
  end


  def get_last_image_id(region)
    #last_ami_id
    begin
      last_ami_id = Net::HTTP.get(URI(BUCKET_URL+get_ami_s3_file_name(region)))
    rescue Exception => e
      puts "Exception handled while getting last image id: #{e.message}"
    end
    last_ami_id
  end

  def delete_image(image_id, region)
    fog = get_fog_by_region(region)
    begin
      fog.deregister_image(image_id)
    rescue Exception => e
      puts "Exception handled while deleting image: #{e.message}"
    end

  end

  def install_ansible
    ssh(%Q(sudo apt-get install -y software-properties-common))
    ssh(%Q(sudo apt-add-repository -y ppa:ansible/ansible))
    ssh(%Q(sudo add-apt-repository "deb http://archive.ubuntu.com/ubuntu $(lsb_release -sc) main universe restricted multiverse"))
    ssh(%Q(sudo apt-get update))
    ssh(%Q(sudo apt-get install -y ansible))
  end

  def ansible_provision(playbook, env = {})
    ansible_env = ''
    unless env.empty?
      ansible_env = env.map { |k, v| "#{k}=#{v}" }.join(' ')
    end

    scp(File.join(File.dirname(__FILE__), "playbooks/#{playbook}"), "/tmp/#{playbook}")
    ssh("sudo ansible-playbook -e '#{ansible_env}' -i localhost -c local /tmp/#{playbook}")
  end

  def scp(source, dest)
    @instance.scp_upload(source, dest, :recursive => true)
  end

  def ssh(cmd)
    result = @instance.ssh(cmd)
    raise("SSH command failed: #{cmd}, !!result: #{result}") if result[0].status != 0
  end

  def get_ami_s3_file_name(region)
    "#{region}_#{@image_description}#{AMI_S3_SUFFIX}"
  end

  def get_ami_name(region)
    "#{region}_#{@image_description}_#{@ami_version}"
  end

  def clean_old_ami(region)
    previous_ami_id = get_last_image_id(region)
    delete_image(previous_ami_id, region)
  end

  def get_fog_by_region(region)
    Fog::Compute.new(
        :provider => 'AWS',
        :region => region,
        :aws_access_key_id => @aws_access_key_id,
        :aws_secret_access_key => @aws_secret_key
    )
  end


  private :check_for, :save_ami_id

end
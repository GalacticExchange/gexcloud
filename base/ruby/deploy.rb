require 'net/http'
require 'zlib'


require_relative '../../deploy_credentials/credentials.rb'
require_relative '../../deploy_credentials/sync_box'

require_relative "../ruby_scripts/common"

def app_name_from_file_name(file_name)
  file_name[CONT_DIR.length + 1 .. file_name.index("-version.txt") - 1]
end

def box_name_from_file_name(file_name)
  file_name[BOX_DIR.length + 1 .. file_name.index("-version.txt") - 1]
end

def rsync(address, password, local, remote)
  sh "sshpass -p '#{password}' rsync --progress -avz -e ssh #{local} #{address}:#{remote}"
end


def scp(address, password, local, remote)
  sh "sshpass -p '#{password}' scp -p -o StrictHostKeyChecking=no  #{local} #{address}:#{remote}"
end


def scp_local(where, local, remote)
  puts where
  scp SSH_ADDRESS_FILES_MAIN, LOCAL_PASSWORD, local, remote if where == "main"
  scp SSH_ADDRESS_MASTER_MAIN, LOCAL_PASSWORD_MASTER, local, remote if where == "master_main"
  scp SSH_ADDRESS_MASTER_DEV, LOCAL_PASSWORD_MASTER, local, remote if where == "master_dev"
  scp SSH_ADDRESS_MASTER_PROD, PROD_PASSWORD_MASTER, local, remote if where == "master_prod"
end

def rsync_local(where, local, remote)
  puts where
  rsync SSH_ADDRESS_FILES_MAIN, LOCAL_PASSWORD, local, remote if where == "main"
  rsync SSH_ADDRESS_FILES_DEV, LOCAL_PASSWORD, local, remote if where == "dev"
  rsync SSH_ADDRESS_MASTER_MAIN, LOCAL_PASSWORD_MASTER, local, remote if where == "master_main"
  rsync SSH_ADDRESS_MASTER_DEV, LOCAL_PASSWORD_MASTER, local, remote if where == "master_dev"
  rsync SSH_ADDRESS_MASTER_PROD, PROD_PASSWORD_MASTER, local, remote if where == "master_prod"
end


def create_version_file(version, size, version_path, file_path)
  sh "echo version=#{version} > #{version_path}"
  sh "echo size=#{size} >> #{version_path}"
  sh "echo checksum=#{Zlib::crc32(File.read(file_path), 0)} >> #{version_path}"
end

def ssh_cmds (address, password, *cmds, container: nil)
  cmds.each do
    ssh_cmd(address, password, cmd, container)
  end
end

def ssh_cmd (address, password, cmd, container = nil)
  if container.nil?
    sh "sshpass -p '#{password}' ssh #{address} '#{cmd}'; "
  else
    sh "sshpass -p '#{password}' ssh #{address} 'docker exec -i #{container} #{cmd}'; "
  end
end

def ssh_cmd_server (where, cmd, container = nil)
  ssh_cmd(SSH_ADDRESS_FILES_MAIN, LOCAL_PASSWORD, cmd, container) if where == "main"
  ssh_cmd(SSH_ADDRESS_MASTER_MAIN, LOCAL_PASSWORD_MASTER, cmd, container) if where == "master_main"
  ssh_cmd(SSH_ADDRESS_MASTER_PROD, PROD_PASSWORD_MASTER, cmd, container) if where == "master_prod"
end

def ssh_exec (address, password, cmd)
  # noinspection RubyUnusedLocalVariable
  c = "sshpass -p '#{password}' ssh #{address}  '#{cmd}'"
  #{c}`
end

def ssh_exec_local (cmd, where)
  ssh_exec(SSH_ADDRESS_FILES_MAIN, LOCAL_PASSWORD, cmd) if where == "main"
  ssh_exec(SSH_ADDRESS_FILES_DEV, LOCAL_PASSWORD, cmd) if where == "dev"
  ssh_exec(SSH_ADDRESS_MASTER_MAIN, LOCAL_PASSWORD_MASTER, cmd) if where == "master_main"
  ssh_exec(SSH_ADDRESS_MASTER_DEV, LOCAL_PASSWORD_MASTER, cmd) if where == "master_dev"
end

def get_box_file_names_local(where)
  boxes = ssh_exec_local where, "ls #{BOX_DIR}/*.txt"
  box_file_names = []
  boxes.each_line do |file|
    box_name = box_name_from_file_name file
    url = LOCAL_BOX_URL + box_name + "-version.txt"
    puts "Retriving " + url
    version_info = Net::HTTP.get(URI.parse(url))
    version = get_version_from_file version_info
    bfn = box_file_name box_name, version
    box_file_names.push(bfn)
    box_file_names.push(bfn)
  end
  puts box_file_names
  return box_file_names
end

def get_container_file_names_local(where)
  containers = ssh_exec_local where, "ls #{CONT_DIR}/*.txt"
  container_file_names = []
  containers.each_line do |file|
    app_name = app_name_from_file_name file
    url = LOCAL_CONTAINER_URL + app_name + "-version.txt"
    puts "Retriving " + LOCAL_CONTAINER_URL + app_name + "-version.txt"
    version_info = Net::HTTP.get(URI.parse(url))
    version = get_version_from_file version_info
    cfn = container_file_name app_name, version
    container_file_names.push(cfn)
  end
  puts container_file_names
  return container_file_names
end


def clean_old_local_boxes(where)
  ssh_cmd_server where, 'mkdir -p /tmp/tempboxes', "gex-files"
  get_box_file_names_local.each do |fileName|
    ssh_cmd_server where, "mv #{BOX_DIR}/#{fileName} /tmp/tempboxes | true", "gex-files"
  end
  ssh_cmd_server where, "rm -rf  #{BOX_DIR}/*.box", "gex-files"
  ssh_cmd_server where, "mv -f  /tmp/tempboxes/* #{BOX_DIR} |true", "gex-files"
end


def clean_old_local_containers(where)
  ssh_cmd_server where, 'mkdir -p /tmp/tempcontainers', "gex-files"
  get_container_file_names_local.each do |fileName|
    ssh_cmd_server where, "mv #{CONT_DIR}/#{fileName} /tmp/tempcontainers/ | true"
  end
  ssh_cmd_server where, "rm -rf  #{CONT_DIR}/*.tar", "gex-files"
  ssh_cmd_server where, "rm -rf  #{CONT_DIR}/*.tar", "gex-files"
  ssh_cmd_server where, "mv -f  /tmp/tempcontainers/* #{CONT_DIR} |true", "gex-files"
end


NGNX_BASE = "/usr/share/nginx/html"

def deploy_single_box_to_server(where, box_file_name)
  size=`stat --printf="%s" /tmp/boxes/#{box_file_name}`
  version_file_name = box_file_name.sub(".box", "-version.txt")


  create_version_file(VERSION, size, "/tmp/boxes/#{version_file_name}", "/tmp/boxes/#{box_file_name}")

  if where == "aws"
    sh "ln /tmp/boxes/#{box_file_name} /tmp/boxes/gex-#{VERSION}-#{box_file_name}"
    upload_amazon "/tmp/boxes/gex-#{VERSION}-#{box_file_name}", "gex-boxes", false
    upload_amazon "/tmp/boxes/#{version_file_name}", "gex-boxes", true
  else
    ssh_cmd_server where, "rm -rf #{NGNX_BASE}/boxes/*#{box_file_name}", "gex-files"
    ssh_cmd_server where, "mkdir -p #{NGNX_BASE}/boxes/", "gex-files"
    ssh_cmd_server where, "chmod a+rwx #{NGNX_BASE}/boxes", "gex-files"
    rsync_local where, "/tmp/boxes/#{box_file_name}", "/tmp/gex-#{box_file_name}"
    ssh_cmd_server where, "sudo docker cp /tmp/gex-#{box_file_name} gex-files:#{NGNX_BASE}/boxes/gex-#{VERSION}-#{box_file_name}"
    scp_local where, "/tmp/boxes/#{version_file_name}", "/tmp/#{version_file_name}"
    ssh_cmd_server where, "sudo docker cp /tmp//#{version_file_name} gex-files:#{NGNX_BASE}/boxes/#{version_file_name}"
  end
end


DEB_DIR = "debpackage/build"


def deploy_deb_to_server(where, deb_file_name, bucket = "debian")
  prefix = deb_file_name[0, deb_file_name.index("_")]
  version = deb_file_name[deb_file_name.index("_") + 1 .. -1 - ".deb".length]
  size=`stat --printf="%s" #{DEB_DIR}/#{deb_file_name}`
  version_file_name = prefix + "-version.txt"
  create_version_file(version, size, "#{DEB_DIR}/#{version_file_name}", "#{DEB_DIR}/#{deb_file_name}")
  if where == "aws"
    upload_amazon "#{DEB_DIR}/#{version_file_name}", "gex-#{bucket}", true
    upload_amazon "#{DEB_DIR}/#{deb_file_name}", "gex-#{bucket}", false
  else
    ssh_cmd_server where, "rm -rf #{NGNX_BASE}/#{bucket}", "gex-files"
    ssh_cmd_server where, "mkdir -p #{NGNX_BASE}/#{bucket}", "gex-files"
    ssh_cmd_server where, "chmod a+rwx #{NGNX_BASE}/#{bucket}", "gex-files"
    scp_local where, "#{DEB_DIR}/#{version_file_name}", "/tmp/#{version_file_name}"
    scp_local where, "#{DEB_DIR}/#{deb_file_name}", "/tmp/#{deb_file_name}"
    ssh_cmd_server where, "docker cp /tmp/#{version_file_name} gex-files:#{NGNX_BASE}/#{bucket}/#{version_file_name}"
    ssh_cmd_server where, "docker cp /tmp/#{deb_file_name} gex-files:#{NGNX_BASE}/#{bucket}/#{deb_file_name}"
  end
end

def deploy_master(type)
  where = "master_" + type
  ssh_cmd_server where, "mkdir -p /tmp/boxes"
  scp_local where, "/tmp/boxes/master.box", "/tmp/boxes/master.box"
  ssh_cmd_server where, "cd /disk2/vagrant/master; vagrant halt --force #{type}"
  ssh_cmd_server where, "cd /disk2/vagrant/master; vagrant destroy --force #{type}"
  ssh_cmd_server where, "cd /disk2/vagrant/master; vagrant box add  --force  gex/base_master /tmp/boxes/master.box  "
  ssh_cmd_server where, "cd /disk2/vagrant/master; vagrant up #{type}"
end

def deploy_master_cont(where, type)
  location = "master_" + where
  rsync_local location, "../docker/hadoop_#{type}_master.tar", "/disk2/"
  rsync_local location, "../docker/hue_#{type}.tar", "/disk2/"
  ssh_cmd_server location, "cd /mount/vagrant/master; ./update_containers.rb"
end

def vsh (command)
  sh "vagrant ssh build -c 'sudo " + command + "'"
end


def upload_amazon(file_path, bucket_name, invalidate)
  Aws.config.update({
                        :access_key_id => ACCESS_KEY_ID,
                        :secret_access_key => SECRET_ACCESS_KEY
                    })

  s3 = Aws::S3::Resource.new(region: 'us-west-1')


  file_name = File.basename(file_path)
  s3.bucket(bucket_name).object(file_name).upload_file(file_path, {acl: 'public-read'})

  #returning public url
  url = s3.bucket(bucket_name).object(file_name).public_url

  if invalidate
    aws_invalidate(bucket_name, file_name)
    puts "Invalidated"
  end
  puts "Uploaded to AWS"
  return url
end

def clear_bucket_aws(bucket_name)
  Aws.config.update({
                        :access_key_id => ACCESS_KEY_ID,
                        :secret_access_key => SECRET_ACCESS_KEY
                    })

  s3 = Aws::S3::Resource.new(region: 'us-west-1')
  s3.bucket(bucket_name).clear!
end

def aws_invalidate(bucket_name, file_name)
  Aws.config.update({
                        :access_key_id => ACCESS_KEY_ID,
                        :secret_access_key => SECRET_ACCESS_KEY
                    })

  # noinspection RubyArgCount
  cloudfront = Aws::CloudFront::Client.new(
      region: 'us-west-2'
  )

  cloudfront.create_invalidation({
                                     distribution_id: CLOUDFRONT_IDS[bucket_name], # required
                                     invalidation_batch: {# required
                                                          paths: {# required
                                                                  quantity: 1, # required
                                                                  items: ["/#{file_name}"],
                                                          },
                                                          caller_reference: "invalidation-#{Time.now.to_i}", # required
                                     },
                                 })

end


def sync_single_box_to_server(box_file_name)
  size=`stat --printf="%s" /tmp/boxes/#{box_file_name}`
  version_file_name = box_file_name.sub(".box", "-version.txt")
  create_version_file(VERSION, size, "/tmp/boxes/#{version_file_name}", "/tmp/boxes/#{box_file_name}")
  upload_amazon "/tmp/boxes/#{version_file_name}", "gex-boxes", true
  sh "ln /tmp/boxes/#{box_file_name} /tmp/boxes/gex-#{VERSION}-#{box_file_name}"
  sync_box("/tmp/boxes/gex-#{VERSION}-#{box_file_name}")
end

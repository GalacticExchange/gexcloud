$container = nil


def use_container(c)

  if c == nil
    throw Exception.new 'Nil container'
  end
  assert (c != 'container'), "Incorrect container name #{$container}"
#  assert /container.length > 0/
  puts "Docker:Using container #{c}"
  $container = c
  $weave_host = ''
  $weave_option = ''

  aws_check
end


BOOTSTRAP_FILE_CONTENTS = <<-BASH
#!/bin/bash

source /etc/profile

echo "AFTER_CREATE" >> /tmp/INIT_LOG

AFTER_CREATE="/after-create"
FIRST_RUN="/etc/first_run.sh"

echo "Executing after create"

if [ -f "$AFTER_CREATE" ]
then
source "${AFTER_CREATE}"
rm "${AFTER_CREATE}"
fi

echo "Executing first run"

echo "FIRST RUN" >> /tmp/INIT_LOG

if [ -f "$FIRST_RUN" ]
then
source "${FIRST_RUN}"
rm "${FIRST_RUN}"
fi

set +x

echo "LOCK_WAIT" >> /tmp/INIT_LOG

while  [  -f /INIT_LOCK ];
do
sleep 0.1
done


set +e

echo "INIT_SH" >> /tmp/INIT_LOG

source /etc/init.sh

  while true
    do
    sleep 1000
    done
BASH


BOOTSTRAP_FILE_TMP_NAME = '/tmp/gex_etc_bootstrap_sh'

BOOTSTRAP_FILE_NAME = '/etc/bootstrap.sh'
BOOTSTRAP_FILE_APP_NAME = '/etc/bootstrap'

File.open(BOOTSTRAP_FILE_TMP_NAME, 'w+') do |f|
  f.write(BOOTSTRAP_FILE_CONTENTS)
end

`chmod a+x #{BOOTSTRAP_FILE_TMP_NAME}`


$executed_aws_check = false

def get_weave_address
  coordinator_ip = `cat /etc/node/nodeinfo/COORDINATOR_IP`.strip
  contents = `ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i /etc/node/nodeinfo/ClusterGX_key.pem vagrant@#{coordinator_ip} ruby /home/vagrant/get_ip.rb`
  if contents.to_s.empty?
    raise "Can't get ip"
  end
  contents.strip
end

def aws?
  File.read("#{NODE_INFO_DIR}/CLOUD_TYPE").strip.eql?('AWS')
end

$weave_host = ''

def set_weave_options
  unless $weave_host.empty?
    return
  end
  if aws?
    $weave_host = '-H unix:///var/run/weave/weave.sock'
    $weave_cidr_option = "-e WEAVE_CIDR=#{get_weave_address}/16 --add-host hadoop-master-#{get_info('CLUSTER_ID')}.gex:#{get_info('MASTER_IP')}" #if $weave_cidr_option.to_s.empty?
  end
end


def deb_file_name(version)
  'gexnode_' + version + '.deb'
end


def container_file_name(app_name, version)
  'gex-' + app_name + '-'+ version + '.tar'
end

def box_file_name(box_name, version)
  'gex-' + version + '-'+ box_name + '.box'
end

def texec(cmd, checkreturn = true)
  puts cmd
  result = `#{cmd}`
  if $?.success? || $?.exitstatus == 129
    return result;
  else
    if checkreturn
      throw Exception.new "#{cmd} returned status #{$?.exitstatus}, #{result}"
    end
  end
end


def aws_check

  if $executed_aws_check
    return
  else
    $executed_aws_check = true
  end

  if `dmidecode -s bios-version`.include?('amazon') && !Dir.exist?('/mount/ansible')
    `echo AWS > #{NODE_INFO_DIR}/CLOUD_TYPE`

    add_var('_aws', true)
    #ENV['_aws_main'] = 'main' if ENV['_openvpn_ip_address'] == '51.1.0.1'
  else
    if Dir.exist? NODE_INFO_DIR
      `echo NONE > #{NODE_INFO_DIR}/CLOUD_TYPE`
    end
  end
end


def xexec(command, container = nil)
  if container == nil
    texec(command)
  else
    dexec(command, container)
  end
end

def xcp(src, dst, container = nil)
  if container == nil
    if src == dst
      return
    end
    texec("cp -f #{src} #{dst} ")
  else
    dcp(src, dst, container)
  end
end

def dexec(command, c = nil)
  c = $container if c == nil
  assert_nnil c, 'Nil container'
  assert_nnil command, 'Nil command '
  texec "docker exec -t #{c}  #{command}", true
end

def dexec_background(command)
  dexec "bash -c 'nohup #{command} >/dev/null 2>&1 &'"
end


def texecs(*command)
  command.each do |c|
    texec c
  end
end

def xexecs(*command, container: nil)
  command.each do |c|
    xexec c, container
  end
end


def dexecs(*command)
  command.each do |c|
    dexec c
  end
end

def dexecs_parallel(*commands)
  Parallel.each(commands) do |c|
    dexec c
  end
end


def dstop(checkreturn = true)
  if $container == nil
    throw Exception.new 'Nil container'
  end
  texec "docker stop #{$container}", checkreturn
end

def drm(container = nil)
  if container.nil?
    container = $container
  end
  if container == nil
    throw Exception.new 'Nil container'
  end

  return system("docker rm -f #{container}")
end

def dfile_exists?(file)
  exists = system("docker cp #{$container}:#{file} /tmp/#{$container}_junkfile")
  return exists unless exists

  texec "rm /tmp/#{$container}_junkfile"
  return exists
end


def ddir_exists?(dir)
  return system("docker cp #{$container}:#{dir} /tmp/#{$container}_junkdir")
end

def dcp(src, dst, checkreturn = true, c: nil)
  assert !dst.include?('hadoop-master')
  assert !dst.include?('hue-master')
  if c.nil?
    c = $container
  end
  texec "docker cp '#{src}' '#{c}:#{dst}'", checkreturn
end

def dcp_reverse(src, dst)
  texec "docker cp #{$container}:#{src} #{dst}"
end


def dcp_out(src, dst)
  texec "docker cp #{$container}:#{src} #{dst}"
end


def dmark_disabled
  texec "touch /etc/systemd/system/#{$container}.disabled"
end


VOLUMES = %w(/data /etc /var/log /home /root)


def volumes_string

  vs = ''

  VOLUMES.each do |v|

    if File.exists?("#{container_files_dir}#{v}") && !Dir.exists?("#{container_files_dir}#{v}")
      vs = vs + " -v #{container_files_dir}#{v}"
    else
      vs = vs + " -v #{volume_name(v)}"
    end
    vs = vs + ":#{v}"
  end

  return vs
end

def volume_name(v)
  return $container + v.gsub('/', '_')
end

def volume_path(v)
  data = texec "docker volume inspect #{volume_name(v)}".strip
  parse = JSON.parse data
  return assert_dir(parse[0]['Mountpoint'])
end

def link_volumes(volumes)
  files_dir = container_files_dir
  puts volumes.inspect
  volumes.each do |v|
    next if v.is_a? Array

    unless File.exists?("#{container_files_dir}#{v}") && !Dir.exists?("#{container_files_dir}#{v}")
      target = "#{files_dir}#{v}"
      unless Dir.exists? target
        texec "mkdir -p #{target}"
        texec "rmdir #{target}"
      end
      texec "ln -s #{volume_path(v)} #{target}"
    end
  end

end

def erase_volumes(volumes)
  volumes.each do |v|
    next if v.is_a? Array
    target = "#{container_files_dir}#{v}"
    texec "unlink #{target}", false
    texec "docker volume rm -f #{volume_name(v)}", false
  end
end


def gex_create_slave_container(tag, cmd, ip, host_records: [], volumes: [], options: '')

  assert_nnil tag, cmd, $container, get_node
  set_weave_options

  dcreate_container(tag, cmd, volumes, ip, "#{$container}-#{get_node}", get_info('DNS_IP'),
                    host_records: host_records, options: "#{$weave_cidr_option} #{options}")

end


def dstart
  texec "docker start #{$container}"
end


def drestart
  `systemctl daemon-reload`
  texec "systemctl stop   #{$container} | true"
  texec "systemctl  start #{$container}"
end

def dimport(file, image_name: nil, import_options: '')
  if image_name.nil?
    image_name = "gex/#{$container}"
  end

  texec "docker rmi #{image_name}", false
  texec "docker import #{file} #{image_name} #{import_options}"
end

def drmi(image)
  texec "docker rmi #{image} |true"
end

def ddestroy(image = nil)
  unless image.nil?
    image ="gex/#{$container}"
  end
  disable_and_remove_service $container
  drm
  disable_and_remove_service "vpnclient_#{$container}"
end


def pull_from_container(filename)
  tmpfile = get_tmp_name filename
  texec("rm -rf #{tmpfile}", false)
  dcp_reverse filename, tmpfile

  tmpfile
end

def push_to_container(filename)
  tmpfile = get_tmp_name filename
  assert_file(tmpfile)
  dcp tmpfile, filename
  return tmpfile
end

def xpull(filename, container = nil)
  if container.nil?
    return filename
  end
  tmpfile = get_tmp_name filename
  dcp_reverse filename, tmpfile
  return tmpfile
end

def xpush(filename, container = nil)
  if container.nil?
    return filename
  end
  tmpfile = get_tmp_name filename
  assert_file(tmpfile)
  dcp tmpfile, filename
  return tmpfile
end


def create_init_lock
  texec 'touch /tmp/INIT_LOCK'
  dcp '/tmp/INIT_LOCK', '/INIT_LOCK'
end

def remove_init_lock
  assert_dpath '/INIT_LOCK'
  dexec 'rm -f /INIT_LOCK'
end

def dexists?
  system("docker inspect #{$container}")
  return ($?.exitstatus == 0)
end

def drunning?
  return system("docker exec #{$container} true")
end


def wait_until_running
  retries = 30
  until system("docker exec #{$container} true") || retries < 0
    sleep 0.1
    retries == retries - 1
  end
  assert_drunning
end

def container_dir
  return "#{CONTAINER_DIR}/#{$container}"
end


def container_hosts
  File.join(container_dir,'hosts')
end

def container_files_dir
  File.join(container_dir, 'files')
end

def container_resolv
  File.join(container_dir, 'resolv.conf')
end

def container_file(file)
  File.join(container_files_dir, file)
end


def init_container_dir(recreate = false)
  if recreate
    return
  end
  remove_and_create_dir container_files_dir
end


def init_container_hosts(ip, hostname, host_entries = [])
  lines = ["127.0.0.1 localhost\n",
           "#{ip} #{hostname}.gex #{hostname} \n"]

  host_entries.each do |h|
    ip = h[:ip]; dn = h[:domain_name]; al = h[:aliases]
    assert_ip ip
    assert_nnil dn, al

    lines.push("#{ip} #{dn} #{al} \n")
  end

  create_file_with_lines container_hosts, lines
end


def init_container_resolv(dns_ip)
  assert_ip dns_ip
  lines = ["nameserver #{dns_ip}\n",
           "nameserver 8.8.8.8\n"]
  create_file_with_lines container_resolv, lines
end


def dget_config
  return assert_file("/disk2/var/lib/docker/containers/#{$container}/config.v2.json")
end

def dparse_config
  file = dget_config
  assert_nnil file
  contents = IO.read(file)
  return JSON.parse contents
end

def dwrite_config(vars)

  f = dget_config
  File.open(f, 'w') {|file| file.write(vars.to_json)}
  puts "Writing file #{f}"

end


def dcreate_container(image_tag, cmd, volumes, ip, host_name, dns_ip, host_records: [], options: '', recreate: false, add_default_volumes: true)

  assert_nnil image_tag, dns_ip
  assert_ip dns_ip
  assert_ip ip

  assert_hostname host_name


  #--cap-add=NET_ADMIN
  options = '--privileged -v /dev/log:/dev/log ' \
      " --dns #{dns_ip} --dns 8.8.8.8 #{options} "

  if volumes != []
    if add_default_volumes
      options = options + " #{volumes_string} "
    end

    # add extra volumes
    s_v = ""
    volumes.each do |v|
      if v.is_a? Array
        s_v << "-v #{v[0]}:#{v[1]}"
      end
    end

    options << s_v
  end


  mac_file = "/etc/node/network/macs/#{$container}_eth1"

  if File.exist? mac_file
    File.delete mac_file
  end

  system("docker rm -f #{$container}")

  s = $?.exitstatus

  if s != 0 && s != 1
    throw Exception.new "Docker rm returned error code #{s}"
  end


  init_container_dir recreate

  #TODO
  host_name = host_name.tr('_', '-')


  init_container_hosts(ip, host_name, host_records)


  init_container_resolv(dns_ip)


  id = (texec "docker #{$weave_host } create  #{options} --name #{$container} --label gex=gex -h #{host_name} -v #{container_hosts}:/etc/hosts -v #{container_resolv}:/etc/resolv.conf #{image_tag}  #{cmd}").strip


  unless recreate

    if cmd == BOOTSTRAP_FILE_NAME
      dcp BOOTSTRAP_FILE_TMP_NAME, BOOTSTRAP_FILE_NAME
    end

    if cmd == BOOTSTRAP_FILE_APP_NAME


      unless dfile_exists? BOOTSTRAP_FILE_APP_NAME
        dcp BOOTSTRAP_FILE_TMP_NAME, BOOTSTRAP_FILE_APP_NAME
      end

    end

  end


  unless volumes.nil? || recreate
    erase_volumes volumes
    link_volumes volumes
  end


  unless recreate
    add_contaner_to_avahi(ip)
  end


  return id
end


def install_container(file_path, image_name: nil, import_options: '')

  if file_path.end_with?('.gz')
    filename_tar = file_path.chomp('.gz')
    texec "gunzip #{file_path}"

    unless filename_tar == "/tmp/#{$container}.tar"
      texec "mv #{filename_tar} /tmp/#{$container}.tar"
    end

    full_path = "/tmp/#{$container}.tar"
  else
    full_path = file_path
  end

  ddestroy image_name

  dimport(full_path, image_name: image_name, import_options: import_options)

  texec "rm -f /tmp/#{image_name}.tar"

end


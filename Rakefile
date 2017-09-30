require_relative "common/config/config"
require_relative "base/ruby_scripts/common"


desc "Create networks"
task :create_networks do
  texec "docker network create -d macvlan -o parent=eth0 --subnet 10.2.0.0 --gateway 10.2.1.1 public"
  texec "docker network create -d macvlan -o parent=overlay --subnet 51.0.0.0/9 overlay"
end

desc "Build container"
task :build, [:name] do |_, args|
  name = args[:name]
  assert_nnil name, "Rake missing container name parameter"
  exec "cd #{name}; sudo docker build -t #{name} . "
end

desc "Run container"
task :run, [:name, :type] do |_, args|
  name = args[:name]
  assert_nnil name, "Rake missing container name parameter"
  gexcloud_create_configure_and_run_container name, args[:type]
  # Check network connectivity
  dexec "ping -c  1 8.8.8.8"
end
desc "Re-run container"
task :rerun, [:name, :type] do |_, args|
  name = args[:name]
  assert_nnil name, "Rake missing container name parameter"
  gexcloud_create_configure_and_run_container name, args[:type], recreate: true
  # Check network connectivity
  dexec "ping -c  1 8.8.8.8"
end




desc "Up box main dev or prod"


DEFAULT_BOXES = %w{files dns  openvpn rabbit proxy webproxy api }

DEFAULT_CONTAINERS = %w{ kafka }

ALL_BOXES = {
             "main" => DEFAULT_BOXES,
             "prod" => DEFAULT_BOXES
}


def vagrant_cmd_list(cmd, boxes, type, dont_stop = false)
  if boxes == nil
    raise ArgumentError, "Nil boxes"
  end
  boxes.each do |box|
    if dont_stop
      begin
        vagrant_cmd(cmd, box, type)
      rescue
        puts "Command #{cmd} failed, continuing"
      end
    else
      vagrant_cmd(cmd, box, type)
    end
  end
end

def vagrant_cmd_all(cmd, type, dont_stop = false)

  if File.exist? '/etc/GEX_BOXES'
    # noinspection RubyUnusedLocalVariable
    boxes = File.foreach('/etc/GEX_BOXES').map { |line| line.split(' ') }
  else
      boxes = ALL_BOXES["#{type}"]
  end

  if File.exist? '/etc/GEX_CONTAINERS'
      boxes = File.foreach('/etc/GEX_CONTAINERS').map { |line| line.split(' ') }
  else
      boxes = ALL_BOXES["#{type}"]
  end
  if boxes == nil
    raise ArgumentError, "Box list #{type} does not exist"
  end
  vagrant_cmd_list cmd, boxes, type, dont_stop
end





def vagrant_cmd(cmd, box, type)
  sh "cd #{box}; vagrant #{cmd} #{type}"
end

def vagrant_cmd_background(cmd, box, type)
  sh "cd #{box}; vagrant #{cmd} #{type} > /tmp/#{type}_#{box}.log &"
end


desc "Up all boxes main dev or prod"
task :up_all, [:type] do |task, args|
  vagrant_cmd_all "up", args[:type]
end

desc "Halt all boxes main dev or prod"
task :halt_all, [:type] do |task, args|
  vagrant_cmd_all "halt", args[:type]
end


desc "Destroy all boxes"
task :destroy_all, [:type] do |task, args|
  vagrant_cmd_all "destroy -f", args[:type], true
  if args[:type] == "prod"
    `pkill VBoxHeadless`
  end
end

desc "Up box main dev or prod, prod_gex1 or prod_gex2"
task :up, [:box, :type] do |task, args|
  puts #{args[:box]}
  puts args[:type]
  vagrant_cmd("up", args[:box], args[:type])
end

desc "Halt box main dev or prod"
task :halt, [:box, :type] do |task, args|
  vagrant_cmd("halt", args[:box], args[:type])
end

desc "Destroy box main dev or prod"
task :destroy, [:box, :type] do |task, args|
  vagrant_cmd("halt -f", args[:box], args[:type])
  vagrant_cmd("destroy -f ", args[:box], args[:type])
end


desc "Ssh to box"
task :ssh, [:box, :type] do |task, args|
  `cd #{args[:box]}; vagrant ssh #{args[:type]}`
end

desc "Up Kafka"
task :up_kafka, [:type] do |task, args|
  settings = KAFKA_SETTINGS["#{args[:type]}".to_sym]
  ENV["private_ip"] = settings[:PRIVATE_IP]
  sh "cd kafka; docker-compose  --file env/#{args[:type]}/docker-compose.yml start"
end

desc "Build Kafka"
task :build_kafka, [:type] do |task, args|
  settings = KAFKA_SETTINGS["#{args[:type]}".to_sym]
  ENV["private_ip"] = settings[:PRIVATE_IP]
  sh "mkdir -p kafka/env/#{args[:type]}"
  sh "j2 kafka/env/docker-compose.yml.j2 > kafka/env/#{args[:type]}/docker-compose.yml"
  sh "cd kafka; docker-compose  --file env/#{args[:type]}/docker-compose.yml up -d"
end


desc "Halt Kafka"
task :halt_kafka, [:type] do |task, args|
  sh "cd kafka; docker-compose  --file env/#{args[:type]}/docker-compose.yml stop"
end

desc "Destroy Kafka"
task :destroy_kafka, [:type] do |task, args|
  sh "cd kafka; docker-compose  --file env/#{args[:type]}/docker-compose.yml kill"
  sh "cd kafka; docker-compose  --file env/#{args[:type]}/docker-compose.yml rm"
end

desc "Set sameserver routes"
task :set_routes do |task, args|
  Chef::Util::FileEdit.new('/lib/systemd/system/docker.service'
  ).insert_line_after_match(/^ExecStart=.*$/, 'ExecStartPost=/sbin/ip route replace  51.64.0.0/10  dev docker0')
end


desc "Setup server server"
task :setup_server, :sameserver do |task, args|

  args.with_defaults(sameserver: "False")

  sh "sudo pip install j2cli"
  sh "sudo groupadd docker|true"
  sh "sudo usermod -aG docker gex"
  sh "sudo curl https://get.docker.com | bash"
  sh "sudo bash -c 'curl -L https://github.com/docker/compose/releases/download/1.7.1/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose;'"
  sh "sudo chmod +x /usr/local/bin/docker-compose"
  sh "sudo cd /tmp; wget https://packages.chef.io/stable/ubuntu/12.04/chefdk_0.14.25-1_amd64.deb;"
  sh "sudo dpkg -i chefdk_0.14.25-1_amd64.deb"
  sh "gem install chef"
  unless :sameserver == "False"
    sh "touch /etc/gex/network/SAME_SERVER"
    sh "touch /etc/gex/network/SAME_SERVER"
    file = Chef::Util::FileEdit.new '/lib/systemd/system/docker.service'
    file.search_file_replace_line(/^ExecStart=.*$/, 'ExecStart=/usr/bin/dockerd --live-restore -H fd://')
    file.insert_line_after_match(/^ExecStart=.*$/, 'ExecStartPost=/sbin/ip route replace  51.64.0.0/10  dev docker0')
    file.write_file
    sh "sudo systemctl daemon-reload"
    sh "sudo systemctl restart docker"
    sh
  end


end
GIT_DIR = '/tmp/framework_templates'

def provision_and_start_created_container(trees)

  create_init_lock

  dstart

  wait_until_running

  dexec 'mkdir -p /opt/gex/config/'

  get_processor.process_template_trees trees, $container

  remove_init_lock

  assert_drunning

end


def gexcloud_create_and_configure_container(container, tag, vars, trees, private_net, public_net, remove_default_net: false, options: '', recreate: false)

  use_container("#{container}")

  init_vars vars

  if public_net.nil? && var_exists?('PORTS')
    ports = _a('PORTS').split
    ports.each do |port|
      options = options + " -p #{port}:#{port} "
    end
  end

  unless public_net.nil?
    options = options + " --network public --ip #{public_net[:ip]} "

    unless public_net[:mac_address].nil?
      options = options + " --mac-address #{public_net[:mac_address]} "
    end
  end


  container_id = dcreate_container tag, '/etc/bootstrap.sh', VOLUMES, public_net[:ip], container, _a('dns_server'), options: options


  dmark_disabled

  puts container_id


  add_vars({'_container' => container})

  texec "docker network connect --ip #{private_net[:ip]} #{private_net[:name]} #{container} "

  unless remove_default_net
    texec "docker network connect bridge #{container} "
  end

  provision_and_start_created_container(trees)

end


def pull

  gex_env = $vars.fetch('_gex_env', '')

  if gex_env == ''
    gex_env = 'main' if  get_info('API_IP').include?('46.172.71.53')
  end

  if gex_env == 'main'

    (Dir.exists? GIT_DIR) ?
        texec("cd #{GIT_DIR}; git pull; git checkout .") :
        texec("cd /tmp; git clone --depth 1 https://github.com/GalacticExchange/framework_templates.git")

  else

    (Dir.exists? GIT_DIR) ?
        texec("cd #{GIT_DIR}; git fetch; git reset --hard prod") :
        texec('cd /tmp; git clone --depth 1 -b prod https://github.com/GalacticExchange/framework_templates.git')

  end


end

def gexcloud_pull_and_process_git_template_trees(app_dir, processor, container)
  pull
  gexcloud_pull_and_process_git_template_tree('general/common', processor, container)
  gexcloud_pull_and_process_git_template_tree(app_dir, processor, container)
end

def gexcloud_pull_and_process_git_template_tree(app_dir, processor, container)
  puts "Processing tree  #{app_dir}"
  t_dir = GIT_DIR + '/' + app_dir +'/templates'
  assert_dir t_dir
  processor.process_template_tree(t_dir, container)
end


def gexcloud_create_configure_and_run_container (name, type, nonetworks: false, recreate: false)

  assert_nnil name, type


  if type == "prod"
    type = :prod
  else
    type = :main
  end


  settings = eval (name.to_s.upcase + '_SETTINGS')


  public_ip = settings[type][:PUBLIC_IP]
  private_ip = settings[type][:PRIVATE_IP]

  assert_nnil private_ip, 'Private IP must always be defined ' + settings[type].inspect


  private_net = {:name => 'overlay', :ip => private_ip}

  if public_ip.nil?
    remove_default_net = true
    public_net = nil
  else
    remove_default_net = false
    public_net = {:name => 'public', :ip => public_ip}
    public_mac = settings[type][:PUBLIC_MAC_ADDRESS]
    unless public_mac.nil?
      public_net[:mac_address] = public_mac
    end
  end


  volumes = nil


  if Dir.exists? '/disk2/gexcloud-main-data/gexcloud'
    volumes = '-v /disk2/gexcloud-main-data/gexcloud:/mount/vagrant  ' \
              '-v /disk2/gexcloud-main-data/scripts:/mount/ansible ' \
              '-v /disk2/gexcloud-main-data/data:/mount/ansibledata '

  elsif Dir.exists? '/mount/vagrant'
    volumes = ' -v /mount/vagrant:/mount/vagrant '  \
               ' -v  /mount/ansible:/mount/ansible ' \
             ' -v /mount/ansibledata:/mount/ansibledata '
  else
    throw Exception.new 'Cant find NSF directories to mount.'
  end


  gexcloud_create_and_configure_container(name, name, settings[type],
                                          [Dir.getwd + '/common/templates', Dir.getwd + "/#{name}/templates"],
                                          private_net, public_net, options: volumes, recreate: recreate)

end

$node = nil

def use_node(n)
  assert_node n
  $node = n
end

def get_node
  assert_nnil $node
  return $node
end


def bare_metal?
  File.exist?('/home/vagrant/gexstarter')
end


def provisioned?
  if File.exist?(File.join(NODE_INFO_DIR, PROVISION_FILE))
    puts 'Already provisioned'
    return true
  end
  false
end

def set_provisioned
  FileUtils.touch(File.join(NODE_INFO_DIR, PROVISION_FILE))
end

def unset_provisioned
  FileUtils.remove_file(File.join(NODE_INFO_DIR, PROVISION_FILE), true)
end

def docker_bare_metal?
  File.exist?('/home/vagrant/bare_metal_docker')
end
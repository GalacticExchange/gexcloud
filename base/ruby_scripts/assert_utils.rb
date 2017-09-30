def assert(expression, string = 'Assert failed')
  unless expression
    throw Exception.new string
  end
end


def assert_dir(dir)
  assert (Dir.exist?(dir) && !dir.end_with?('/')), "Dir #{dir} does not exist"
  return dir
end

def assert_file(file)
  assert (File.exist? file), "File #{file} does not exist"
  return file
end

def assert_dpath(file, message = nil)
  result= system("docker exec #{$container} stat #{file}")
  assert result, "Path #{file} does not exist in container #{$container}. #{message}"
  return file
end

def assert_cluster_id(cluster_id)
  assert cluster_id.to_i > 0, "Invalid clustert id, #{cluster_id}"
  return cluster_id
end


def assert_node_container(node, container)
  assert !node.include?('.') && !container.include?('.') && !(container == 'container') &&
             !(node == 'node'), node + ' ' + container
  node
end

def assert_node(node)
  assert !node.include?('.'), ' ' + node
  node
end

def assert_ip(ip)
  assert ip.include?('.'), ' ' + ip
  ip
end

def assert_hostname(hostname)
  assert !hostname.include?('.'), ' ' + hostname
end


def assert_port(port)
  assert port.to_i < 65000, ' ' + port
  port
end

def assert_node_number(node_number)
  assert node_number.to_i < 1000000
  node_number
end

def assert_nnil(*objects)
  objects.each do |object|
    assert (!object.nil?), "Nil parameter, #{objects.inspect}"
  end
  return objects[0]
end

def assert_path(filename)
  assert !(filename.include? '//') && !(filename.end_with? '/')
  return filename
end

def assert_drunning
  assert drunning?, "Container #{$container} is not running"
end
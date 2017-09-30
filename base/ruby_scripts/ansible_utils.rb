# noinspection RubyResolve
# $Id$

require 'json'


$vars = nil

def init_vars(v = {})
  assert_nnil v
  $vars = {}
  add_vars v
end


def parse_config(server_name)
  assert_nnil $vars['_gex_env']

  ($vars['_gex_env'].start_with?('prod')) ? settings = GLOBAL_SETTINGS[:prod] :
      settings = GLOBAL_SETTINGS[:main]


  settings.each do |k, v|
    $vars[k.to_s] = v
  end
  add_var '_server_name', server_name
end

def parse_vars(server_name)

  $vars = consul_get_cluster_data

  assert_nnil $vars

  parse_config(server_name)

end


def _a(var, throw_exception = true)
  value = $vars[var]
  if throw_exception && (value.nil?)
    throw Exception.new "No such variable #{var} " + $vars.inspect
  end
  value
end

def get_array(var)
  value = $vars[var]
  if value.nil?
    throw Exception.new "No such variable #{var} " + $vars.inspect
  end
  return value
end


def var_exists?(var)
  return $vars[var].nil?
end


def add_item(key, value)
  assert_nnil key, value
  $vars[key] = value
end


def add_var(key, value)
  assert_nnil key, value
  $vars[key] = value
end

def remove_var(key)
  assert_nnil key
  $vars[key] = nil
end

def remove_item(key)
  assert_nnil key
  $vars[key] = nil
end


def add_vars(dictionary)
  dictionary.each do |k, v|
    add_var k.to_s, v
  end
end

def get_ansible_string_vars
  string_vars = {}

  assert_nnil($vars)

  $vars.each do |key, value|
    v = value.to_s
    unless key.include? '.'
      string_vars[key] = v
    end
  end
  string_vars
end


def get_vars
  $vars
end

def get_value(key)
  value = $vars[key]
  if value.nil?
    throw Exception.new "No such variable #{key} in $vars: #{$vars.inspect}"
  end
  value
end

def initiate(server, vars)
  cluster_id = vars['_cluster_id']
  $vars = vars
  parse_config(server)
  add_var('_consul_ports', consul_ports(cluster_id))
  assert_cluster_id(cluster_id)
end

def parse_and_init(server, cluster_id, host = '51.0.1.8')
  #cluster_id = ARGV[0]
  assert_nnil cluster_id, server
  consul_connect(cluster_id, host)
  parse_vars server
  assert_cluster_id(cluster_id)
end


def parse_and_init_node(node_id)
  node_data = consul_get_node_data(node_id)
  node_data = node_data.to_json

  require_relative '/mount/ansible/provisioner/lib/data_converter'
  node_data = DataConverter.convert_node_data(node_data)

  $vars.merge!(node_data)
end

def initiate_app(app_data)
  app_data['_node_number'] = consul_get_node_data(app_data['_node_id']).fetch('_node_number')
  app_data['_node_name'] = consul_get_node_data(app_data['_node_id']).fetch('_node_name')
  app_data['_node_type'] = consul_get_node_data(app_data['_node_id']).fetch('_node_type')
  $vars.merge!(app_data)
  consul_set_app_data(app_data, app_data.fetch('_app_id'))
end


def parse_and_init_app(app_id)
  app_data = consul_get_app_data(app_id)
  app_data = app_data.to_json

  require_relative '/mount/ansible/provisioner/lib/data_converter'
  app_data = DataConverter.convert_app_data(app_data)

  $vars.merge!(app_data)
end
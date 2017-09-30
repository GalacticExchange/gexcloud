require_relative 'common'

container_name = ENV.fetch('container_name').dup
action = ENV.fetch('action').dup

node_name = get_info('NODE_NAME')
container_name.sub!("-#{node_name}", '')


def change_service_state(service_name, action)
  texec "service #{service_name} #{action}"
end

change_service_state(container_name, action)
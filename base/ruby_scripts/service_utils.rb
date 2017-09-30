def iterator_exec(iterations)

  i = 0

  begin

    yield

  rescue => e
    if i <= iterations
      i = i + 1
      sleep 5
      retry
    else
      raise e
    end
  end

end




def enable_and_start_service(service)

  iterator_exec(5) {

    texec "systemctl stop #{service}", false
    texec "systemctl disable #{service}", false
    texec "systemctl enable #{service}"
    texec "systemctl start #{service}", !($container == 'hue' && aws?)
    sleep 3

  }


end

def disable_and_remove_service(service)
  texec "systemctl disable #{service}", false
  FileUtils.rm_f "/etc/systemd/system/#{service}.service"
  FileUtils.rm_f "/etc/systemd/system/#{service}.disabled"
end


def start_service(service)
  texec "systemctl start #{service}"
end

def restart_service(service)
  texec "systemctl restart #{service}"
end

def start_services(*services)
  services.each do |s|
    start_service s
  end
end

def stop_service(service)
  texec "systemctl stop #{service}"
end

def stop_services(*services)
  services.each do |s|
    stop_service s
  end
end

def enable_and_start_container_service
  enable_and_start_service $container
end

def disable_and_remove_container_service
  disable_and_remove_service $container
end

require_relative 'common'

OPENVPN_DIR = '/etc/openvpn/config'
SYSTEMD_DIR = '/etc/systemd/system'


# $Id$


def set_container_vars(novpn = false)

  add_vars({
               '_container_name' => $container,
               '_app_name' => $container
           })


  add_vars({
                 '_container_ip' => get_vpn_ip_address(true, $container),
                 '_vpn_client_ip' => get_vpn_ip_address(true, $container),
                 '_vpn_server_ip' => get_vpn_ip_address(false, $container),
                 '_vpn_server_port' => consul_get_container_vpn_port(get_node, $container),
             })


  if (get_info 'STATIC_IPS') == 'true'
    add_var '_static_ips', 'true'
    add_var '_container_external_ip', `bash -c "cat /etc/node/nodeinfo/CONTAINER_IPS | jq '.#{$container}'"`
  end

  ifname = nil
  if aws?
    ifname = 'ethwe'
    add_var('_aws', true)
  else
    ifname = 'eth1'
  end

  add_var '_container_ifname', ifname

end


def setup_container_service_and_vpn(novpn = false)


  processor = get_processor


  processor.process_template_file "#{SYSTEMD_DIR}/app.service.erb", "#{SYSTEMD_DIR}", destination: "#{SYSTEMD_DIR}/#{$container}.service"
  enable_and_start_container_service

  #return if novpn


  processor.process_template_file "#{SYSTEMD_DIR}/client_vpn.conf.erb", "#{SYSTEMD_DIR}", destination: File.join(OPENVPN_DIR, "client_#{$container}.conf")
  processor.process_template_file "#{SYSTEMD_DIR}/vpnclient_container.service.erb", "#{SYSTEMD_DIR}", destination: "#{SYSTEMD_DIR}/vpnclient_#{$container}.service"

  dexec "mkdir -p #{OPENVPN_DIR}"
  dcp "#{OPENVPN_DIR}/secret.key", "#{OPENVPN_DIR}/secret.key"
  dcp "#{OPENVPN_DIR}/password", "#{OPENVPN_DIR}/password"
  dexecs \
   "chmod 400 #{OPENVPN_DIR}/secret.key"
  "chmod a+r #{OPENVPN_DIR}/password"

  unless dfile_exists? "/usr/sbin/openvpn"

    OPENVPN_PACKAGES.each { |e|
      begin
        dexec "#{e[:install_command]}"
        break
      rescue => ex
        p "Rescued: #{ex} while installing openvpn. OS: #{e[:os_name]}"
      end
    }


  end


  wait_until_running

  dcp "#{OPENVPN_DIR}/client_#{$container}.conf", "#{OPENVPN_DIR}/client_#{$container}.conf"

  enable_and_start_service("vpnclient_#{$container}")


  texec("echo successfully started #{$container}")
end


def disable_and_stop_container_service


  begin

    disable_and_remove_service $container
    disable_and_remove_service "vpnclient_#{$container}"

    texecs \
         "rm -f #{OPENVPN_DIR}/client_#{$container}.conf",
         'systemctl daemon-reload',
         "echo successfully removed #{$container} service"
  rescue
    puts 'got error, continuing'
  end

end


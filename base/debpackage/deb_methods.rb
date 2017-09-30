#'rake' must be required for this methods
#or just require this file from Rakefile.new
DEB_VERSION = '0.1.' + Time.now.to_i.to_s


FRAMEWORK_TEMPLATES = 'https://github.com/GalacticExchange/framework_templates.git'

def pull_sensu(deb_root_dir)
  sh 'rm -rf /tmp/framework_templates'
  sh "git clone #{FRAMEWORK_TEMPLATES} /tmp/framework_templates"
  sh "mv /tmp/framework_templates/node/sensu/plugins/* #{File.join(deb_root_dir, '/etc/sensu/plugins/')}"
  sh "chmod +x #{File.join(deb_root_dir, '/etc/sensu/plugins/*')}"
end

def copy_core_files(package_name)


  deb_base = "/tmp/gex_deb/#{package_name}_#{DEB_VERSION}"
  deb_vagrant = "#{deb_base}/home/vagrant"

  sh "mkdir -p /tmp/gex_deb"
  sh "rm -rf /tmp/gex_deb/*"
  sh "cp -r debpackage/gex_node_skeleton /tmp/gex_deb/"
  sh "mv /tmp/gex_deb/gex_node_skeleton /tmp/gex_deb/#{package_name}_#{DEB_VERSION}"

  sh "cp  * #{deb_vagrant} | true"
  sh "cp -rf auth #{deb_vagrant}"
  sh "cp -rf openvpn  #{deb_vagrant}"
  sh "cp -rf ruby_scripts  #{deb_vagrant}"
  sh "cp -rf sanity_checks  #{deb_vagrant}"
  sh "cp -rf common  #{deb_vagrant}"
  sh "cp -rf roles  #{deb_vagrant}"
  sh "cp -rf slaveservices  #{deb_vagrant}"
  sh "cp -rf update_scripts  #{deb_vagrant}"
  sh "chmod a+x #{deb_vagrant}/ruby_scripts/*"
  sh "mkdir -p #{deb_base}/usr/local/bin/"
  sh "cp common/runslavedocker.bash #{deb_base}/usr/local/bin/runslavedocker.bash"
  sh "chmod a+x #{deb_base}/usr/local/bin/runslavedocker.bash"
  sh "cp common/pipework #{deb_base}/usr/local/bin/pipework"
  sh "chmod a+x #{deb_base}/usr/local/bin/pipework"
  sh "mkdir -p #{deb_base}/etc/systemd/system"
  sh "cp slaveservices/* #{deb_base}/etc/systemd/system"
  sh "mkdir -p #{deb_base}/etc/openvpn/config"
  sh "cp openvpn/* #{deb_base}/etc/openvpn/config"

  pull_sensu(deb_base)
end

def process_control(package_name)
  #count directory size
  size = `du -ks /tmp/gex_deb/#{package_name}_#{DEB_VERSION} |awk '{print $1}'`
  size.strip!

  ENV['DEB_VERSION'] = DEB_VERSION
  ENV['SIZE'] = size
  ENV['PACKAGE_NAME'] = package_name

  sh "j2 /tmp/gex_deb/#{package_name}_#{DEB_VERSION}/DEBIAN/control.j2 > /tmp/gex_deb/#{package_name}_#{DEB_VERSION}/DEBIAN/control"
  sh "rm /tmp/gex_deb/#{package_name}_#{DEB_VERSION}/DEBIAN/control.j2"
end

def build_deb(package_name)
  sh "chmod -R 755 /tmp/gex_deb/#{package_name}_#{DEB_VERSION}/DEBIAN/"
  sh "fakeroot dpkg-deb --build /tmp/gex_deb/#{package_name}_#{DEB_VERSION}"
end

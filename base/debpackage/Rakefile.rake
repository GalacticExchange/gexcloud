require_relative 'deb_methods'

PACKAGE_NAME = 'gexnode'


desc 'create deb'
task :create_deb do

  copy_core_files(PACKAGE_NAME)
  process_control(PACKAGE_NAME)
  build_deb(PACKAGE_NAME)

  sh 'mkdir -p debpackage/build'
  sh 'rm debpackage/build/* | true'
  sh "cp /tmp/gex_deb/#{PACKAGE_NAME}_#{DEB_VERSION}.deb debpackage/build"
end
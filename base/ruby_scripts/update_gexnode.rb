#! /usr/bin/env ruby
#  encoding: UTF-8
# $Id$
require 'net/http'


DEB_URL_MAIN = 'http://46.172.71.53:8090/debian/'
DEB_URL_AWS = 'http://d18ms0xu9tssc7.cloudfront.net'
DEB_PATH_LOCAL = '/tmp/deb_download/'

def texec(cmd)
  puts cmd
  puts `#{cmd}`
end


def deb_file_name(version)
  'gexnode_' + version + '.deb'
end

def get_version_from_file(file_contents)
  file_contents.each_line do |line1|
    cleaned = line1.delete(' ')
    if cleaned.index('version=') >= 0
      version = cleaned['version='.length .. cleaned.length - 2]
      return version
    end
  end
  nil
end


def update_deb(env, version_file)

  texec 'rm -f /etc/node/nodeinfo/PROVISIONED'

  texec 'echo Starting updating deb'
  case env
    when :main
      run_dpkg(download_deb(DEB_URL_MAIN, version_file))
    when :prod
      run_dpkg(download_deb(DEB_URL_AWS, version_file))
    else
      raise 'Argument should be :main or :prod'
  end
  texec 'echo Completed updating deb'
end

def download_deb(base_url, version_file)
  `rm -rf #{DEB_PATH_LOCAL}`
  `mkdir -p #{DEB_PATH_LOCAL}`

  url = URI.join(base_url, version_file)
  version = get_version_from_file(Net::HTTP.get(url))
  file_name = deb_file_name(version)
  file_url = URI.join(base_url, file_name)
  deb_path = File.join(DEB_PATH_LOCAL, file_name)
  texec 'curl -o ' + deb_path + ' ' + file_url.to_s
  deb_path
end

def run_dpkg(pkg_path)
  texec "dpkg -i #{pkg_path}"
end

#update_deb(:prod,'gexnode-version.txt')
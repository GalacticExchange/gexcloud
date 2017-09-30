# noinspection RubyResolve
# $Id$
require 'json'
require 'fileutils'


def remove_files_by_pattern(dir, pattern)
  puts 'Removing files ' + pattern + ' from directory ' + dir
  Dir.glob("#{dir}/#{pattern}").each do |file_name|
    File.delete "#{file_name}"
  end
end


def remove_services_by_wildcard (wildcard)
  system "cd /etc/systemd/system; systemctl stop #{wildcard}.service"
  system "cd /etc/systemd/system; systemctl disable stop #{wildcard}.service"
  `cd /etc/systemd/system; rm -f #{wildcard}.*`
end

def remove_files_by_wildcard (wildcard, container = nil)
  xexec "rm -f #{wildcard}", container
end


def remove_containers_by_substring(substring, container = nil)
  xexec "docker stop $(docker ps -aq --filter name=#{substring})", container
  xexec "docker rm -f $(docker ps -aq --filter name=#{substring})", container
end


def remove_and_create_dir(dir, container = nil)
  xexec "rm -rf #{dir}", container
  xexec "mkdir -p #{dir}", container
  xexec "chmod 755 #{dir}", container
end

def get_tmp_name(filename)
  assert (!filename.end_with? '/'), "Path ends with slash #{filename}"
  return "/tmp/#{$container}" + filename.gsub('/', '_')
end
#!/usr/bin/env ruby

###
# run ansible script on server
# provision.rb <env> <server> <script_file>
# example:
# ruby provision.rb dev rabbit set_dns.yml
#
# -- run script from common/
# ruby provision.rb rabbit common/avahi_uninstall.yml -i devinventory

#
require 'optparse'


# input
server = ARGV[0] || ''
script = ARGV[1] || ''


# options
options = {}
opt_parser = OptionParser.new do |opt|
  opt.banner = "Usage: example.rb [options]"

  opt.on("-v", "--[no-]verbose", "Run verbosely") do |v|
    options[:verbose] = v
  end

  opt.on("-e","--environment ENVIRONMENT","which environment you want server run") do |v|
    options[:environment] = v
  end
  opt.on("-i","--inventory INVENTORY_FILE","which inventory you want to use") do |v|
    options[:inventory] = v
  end

  opt.on("-o","--opt OPTIONS","options") do |v|
    options[:options] = v
  end
end

opt_parser.parse!



#
inventory = options[:inventory] || 'inventory'

#
puts "Running on #{server}, file: #{script}, inventory: #{inventory}"

#
require 'fileutils'

#
script_path = script

#
script_common = false
script_path = "#{script}"

# short path
if script =~ /^[^\/]+$/
  script_path = "#{server}/#{script}"
  unless File.exists?(script_path)
    script_common = true
    script_path = "common/#{script}"
  end
end

unless File.exists?(script_path)
  puts "File #{script_path} not found"
  exit(1)
end



script_tmp_path = nil

script_dir =  File.dirname(script_path)
script = File.basename(script_path)

#puts "script = #{script_path}"
#puts "d = #{script_dir}"
#exit(1)


# playbook in dir
# run playbook from the dir
t = Time.now.utc.to_i
r = [*('a'..'z')].sample(12).join

script_tmp_path = "#{script_dir}/tmp-#{t}-#{r}.yml"
FileUtils.cp "run_script.yml", script_tmp_path

cmd = %{
ansible-playbook -i #{inventory} -l #{server} #{script_tmp_path} -e "server=#{server} script=#{script} #{options[:options]}"
}



puts "cmd=#{cmd}"
#exit

res_output = %x[ #{cmd} ]
exit_code = $?.exitstatus

# remove temp file
unless script_tmp_path.nil?
  File.delete script_tmp_path
end

# output
puts "#{res_output}"


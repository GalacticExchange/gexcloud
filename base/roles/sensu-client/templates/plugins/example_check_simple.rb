#! /usr/bin/env ruby
#  encoding: UTF-8
#
#   check_gex_api_events
#
# DESCRIPTION:
#
# OUTPUT:
#   metric data
#
# PLATFORMS:
#   Linux
#
# DEPENDENCIES:
#   gem: sensu-plugin
#
# USAGE:
#
# NOTES:
#
# LICENSE:
#   Copyright 2012 Sonian, Inc <chefs@sonian.net>
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.


require 'sensu-plugin/check/cli'
require 'json'
require 'bunny'


class CheckGexApiEvents < Sensu::Plugin::Check::CLI
=begin
  option :warn,
         :short => '-w WARN',
         :proc => proc {|a| a.to_i },
         :default => 10

  option :crit,
         :short => '-c CRIT',
         :proc => proc {|a| a.to_i },
         :default => 5
=end

=begin
def run
    total_ram, free_ram = 0, 0


    unknown "invalid percentage" if config[:crit] > 100 or config[:warn] > 100

    percents_left = free_ram*100/total_ram
    message "#{percents_left}% free RAM left"

    critical if percents_left < config[:crit]
    warning if percents_left < config[:warn]
    ok
  end
=end

  def run
    # get message from bunny


    # noinspection RubyUnusedLocalVariable
    v = 50
    data = {type: 'debug_error', message: "test msg"}
    #message "#{v}% value"
    output data.to_json

    #critical if v < config[:crit]
    #warning if v < config[:warn]

    warning
    #ok
  end
end

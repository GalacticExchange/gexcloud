module God
  module Conditions
# Condition Symbol :dns_not_work
# Type: Poll
#
# Trigger when a specified file is touched.
#
# Parameters
# Required
# +resolve_list+ is
# +dns_server+ is [optional]
#
# Examples
#
# Trigger if ...:
#
# on.condition(:dns_not_work) do |c|
# c.resolve_list = {'api.gex'=>'51.0.1.21', 'yahoo.com'=>''}
# end
#
    class DnsNotWork < PollCondition
      attr_accessor :dns_server
      attr_accessor :resolve_list


      def get_dns_ip(domain)
        res_ips = []

        begin
        if self.dns_server.nil?
          cmd = "dig #{domain}"
        else
          cmd = "dig @#{self.dns_server} #{domain}"
        end

        #
        output = `#{cmd}`
        s = output.gsub /^.*ANSWER SECTION.*?(\n|\r\n)/ims, ''
        res_ips = []
        s.lines.each do |s1|
          m = s1=~ /^#{domain}\.\s+\d+\s+IN\s+A\s+([\d\.]+)(\s+|$)/i
          if m
            ip = $1
            res_ips << ip
          end
        end

        rescue => e
# ignored
        end

        res_ips
      end

      def initialize
        super
        self.resolve_list = nil
        self.dns_server = nil
      end

      def valid?
        valid = true
        valid &= complain("Attribute 'resolve_list' must be specified", self) if self.resolve_list.nil?
        valid
      end

      def check_dns
        self.resolve_list.each do |domain, v_correct|
          #
          found_ips = get_dns_ip(domain)
          return true if found_ips.count <=0

          if v_correct!=''
            return true unless found_ips.include?(v_correct)
          end
        end

        false
      end


      def log_file
        '/var/www/logs/god-dns-check.log'
      end

      def test
        bad_res = check_dns

        if bad_res
          now = Time.now.utc
          File.open(log_file, 'a+') do |file|
            d = now.to_datetime
            file.write("#{d}, Cannot resolve DNS - need restart")
            file.write("\n")
          end
        end

        bad_res
      end

    end
  end
end

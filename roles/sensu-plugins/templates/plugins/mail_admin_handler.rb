#! /usr/bin/env ruby
# encoding: UTF-8
# mail_admin_handler.rb
#
# DESCRIPTION:
#   This handler formats messages and send email to admin
#
# OUTPUT:
#
#
# PLATFORMS:
#   All
#
# DEPENDENCIES:
#   gem: redis
#
# USAGE:
#
# LICENSE:
#   Max Ivak maxivak@gmail.com
#   Released under the same terms as Sensu (the MIT license);
#   see LICENSE for details.


require 'sensu-handler'
require 'timeout'
require 'redis'
require 'pony'




class MailAdminHandler < Sensu::Handler
  NOTIFY_EMAIL = 'betauser@galacticexchange.io'
  NOTIFY_FROM_EMAIL = 'betanoreply@galacticexchange.io'

  SMTP_SETTINGS = {
      :address        => "email-smtp.us-west-2.amazonaws.com",
      :port           => 587,
      :domain         => "galacticexchange.io",
      :authentication => :plain,
      :user_name      => "AKIAJWE2GLZ2C27L2L3Q",
      :password       => "AonN0j2h8DlEGNfGrg1GPSjelWY91XAYHN3c2lHFYGzH",
      :enable_starttls_auto => true
  }



  def short_name
    @event['client']['name'] + '/' + @event['check']['name']
  end

  def action_to_string
    @event['action'].eql?('resolve') ? 'RESOLVED' : 'ALERT'
  end

  def handle
    #puts "mail admin start for #{short_name}"

    begin
      timeout 10 do
        # debug
        #file_name = "/etc/sensu/debug_#{@event['client']['name']}_#{@event['check']['name']}.json"
        #sd = @event['check']['executed']
        #d = Time.at(sd.to_i).utc.to_datetime rescue nil
        #File.open(file_name, 'a+') do |file|
        #  file.write("#{d} --")
        #  file.write(JSON.pretty_generate(@event['check']))
        #  file.write(JSON.pretty_generate(@event['check']['output']))
        #end

        # event
        parsed = false
        data = nil
        begin
          data = JSON.parse(@event['check']['output'])
          parsed = true
        rescue => e
          data = @event['check']['output']
        end


        # event presentation
        a_text = []
        a_html = []

        if parsed

          # API event

          data.each do |r|
            #
            if r['data'].is_a? String
              r['data'] = (JSON.parse(r['data']) rescue {})
            end

            type_name = r['data']['type_name']

            a_text << <<-FOO
  #{type_name}. #{r['message']}
  #{JSON.pretty_generate(r)}

  FOO

            a_html << <<-FOO
<b>#{type_name}</b>. #{r['message']}<br>
#{JSON.pretty_generate(r)}<br>
<br>
FOO

          end
        else
          s = data.strip

          unless s.blank?
            # raw text
            a_text << data
            a_html << data
          end


        end

        if a_text.length > 0 || s_html.length > 0
          s_text = "Client: #{@event['client']['name']}"+"\n"+a_text.join('\n')
          s_html = "Client: #{@event['client']['name']}"+"<br>"+a_html.join('<br>')



          # mail
          Pony.mail({
                :to => NOTIFY_EMAIL,
                :from => NOTIFY_FROM_EMAIL,
                :subject => 'notify handler',
                :body => s_text,
                :html_body => s_html,
                :via => :smtp,
                :via_options => SMTP_SETTINGS
            })

        end


        #
        #puts "mail_admin: done"
      end
    rescue Timeout::Error
      puts 'mail_admin handler: -- timed out while attempting to ' + @event['action'] + ' an incident -- ' + short_name
    rescue => e
      puts 'mail_admin handler: exception. ' + "e: #{e.inspect}" + @event['action'] + ', ' + short_name
    end
  end
end

require 'docker'
require 'rake' # for `sh` method

require 'erb'
require 'fileutils'

require 'net/ping'
require 'colorize'

require 'slack-notifier'

require 'parallel'

FRAMEWORK_TEMPLATES = 'https://github.com/GalacticExchange/framework_templates.git'
GIT_DIR = '/tmp/framework_templates'



Chef.event_handler do
  on :run_failed do |exception|
    HandlerSendToSlack::Helper.new.send_msg_on_run_failure(exception)
  end
end
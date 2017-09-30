def rethrow(e, message)
  raise Exception.new "#{message} : \n #{e.message} #{e.backtrace}"
end


def send_exception_to_slack(e)

  h = nil

  begin
    h = Socket.gethostname
  rescue Exception
# ignored
  end


  if $vars.nil?
    t = 'No String Vars'
  else
    t = "#{get_vars.inspect}"
  end

  unless h.nil?
    t = t + "Hostname: #{h} "
  end

  args_attachments = {
      fallback: 'args',
      text: t,
      color: '#00ff00'
  }
  ex_attachment = {
      fallback: 'Exception_message',
      text: "#{e}  #{e.backtrace}",
      color: '#ffff00'
  }


  consul_connect($vars['_cluster_id'])
  gex_env = consul_get_cluster_data.fetch('_gex_env','prod')
  notifier = Slack::Notifier.new(EXCEPTION_URL, channel: "##{gex_env}_errors", username: 'safe_exec')
  notifier.post(text: "Exception #{Time.now}", attachments: [args_attachments, ex_attachment])

end

def safe_exec
  begin
    yield
  rescue SystemExit => exception
    if exception.status != 0
      send_exception_to_slack exception
      if $vars['_server_name']
        consul_delete_lock($vars['_server_name'])
      end
      raise
    end
  rescue Exception => exception
    send_exception_to_slack exception
    if $vars['_server_name']
      consul_delete_lock($vars['_server_name'])
    end
    raise
  end
end


def exception_debug(string)
  throw Exception.new string
end

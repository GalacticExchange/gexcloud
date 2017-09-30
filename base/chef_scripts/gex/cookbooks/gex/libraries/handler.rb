

module HandlerSendToSlack
  # Helper class to send notifications
  # TODO: add env parsing
  class Helper
    EXCEPTION_URL = 'https://hooks.slack.com/services/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'.freeze

    def send_msg_on_run_failure(exception)

      message = "#{exception}\n"

      ex_attachment = {
        fallback: 'Exception_message',
        text: "#{message}",
        color: '#ffff00'
      }

      notifier = Slack::Notifier.new(EXCEPTION_URL, channel: '#bot_test1', username: 'chef-solo')
      notifier.post(text: "Exception | #{Time.now.rfc2822}", attachments: [ex_attachment])
    end
  end
end

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # assets
  config.serve_static_files = true
  config.assets.debug = true
  config.assets.digest = true
  config.assets.raise_runtime_errors = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true


  # active job
  config.active_job.queue_adapter = :sidekiq # inline sidekiq

  #config.active_job.queue_name_prefix = "#{Rails.configuration.SITE_NAME}"
  #config.active_job.queue_name_delimiter = "_"

  # action mailer
  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = true

  #
  ActionMailer::Base.register_interceptor(DevelopmentMailInterceptor)

  #
  #config.action_mailer.delivery_method = :smtp

  # test email - SMTP + Redis
  require 'test_email_redis/test_mail_smtp_delivery'
  ActionMailer::Base.add_delivery_method :my_test_delivery, TestEmailRedis::TestMailSmtpDelivery
  config.action_mailer.delivery_method = :my_test_delivery





=begin
ActionMailer::Base.smtp_settings = {
    :address        => "smtp.gmail.com",
    :port           => 587,
    :domain         => "gmail.com",
    :authentication => :plain,
    :user_name      => "alex.danko@galacticexchange.io",
    :password       => "PH_GEX_PASSWD15",
    :enable_starttls_auto => true
}
=end

  # amazon
  config.action_mailer.smtp_settings = {
      :address        => "email-smtp.us-west-2.amazonaws.com",
      :port           => 587,
      :domain         => "galacticexchange.io",
      :authentication => :plain,
      :user_name      => "AKIAJWE2GLZ2C27L2L3Q",
      :password       => "AonN0j2h8DlEGNfGrg1GPSjelWY91XAYHN3c2lHFYGzH",
      :enable_starttls_auto => true
  }

  #
  #ActionMailer::Base.view_paths= File.join(File.dirname(__FILE__), "../../views")


  # gex_config
  config.gex_env = 'development'


end

Rails.application.configure do

  config.allow_concurrency = true

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
  config.assets.compile = true
  config.serve_static_files = true
  config.assets.debug = true
  config.assets.digest = true

  # Adds additional error checking when serving assets at runtime.
  # Checks for improperly declared sprockets dependencies.
  # Raises helpful error messages.
  config.assets.raise_runtime_errors = false

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  # Raise exceptions instead of rendering exception templates.
  config.action_dispatch.show_exceptions = false

  # Disable request forgery protection in test environment.
  config.action_controller.allow_forgery_protection = false



  # Randomize the order test cases are executed.
  config.active_support.test_order = :random

  # Print deprecation notices to the stderr.
  config.active_support.deprecation = :stderr

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true



  # action mailer
  #config.active_job.queue_adapter = :test
  config.active_job.queue_adapter = :inline

  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = true

  #
  ActionMailer::Base.register_interceptor(DevelopmentMailInterceptor)

  # Redis
  require 'test_email_redis/test_mail_delivery'
  ActionMailer::Base.add_delivery_method :my_test_delivery, TestEmailRedis::TestMailDelivery
  config.action_mailer.delivery_method = :my_test_delivery


  ###
  config.gex_env = 'test'

end

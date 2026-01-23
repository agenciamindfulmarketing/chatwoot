Rails.application.configure do
  # ===============================
  # Básico de produção
  # ===============================
  config.cache_classes = true
  config.eager_load = true

  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # ===============================
  # Arquivos estáticos
  # ===============================
  config.public_file_server.enabled = ActiveModel::Type::Boolean.new.cast(
    ENV.fetch('RAILS_SERVE_STATIC_FILES', true)
  )

  config.public_file_server.headers = {
    'Cache-Control' => "public, max-age=#{1.year.to_i}"
  }

  config.assets.compile = false

  config.action_controller.asset_host = ENV.fetch('ASSET_CDN_HOST') if ENV['ASSET_CDN_HOST'].present?

  # ===============================
  # Active Storage
  # ===============================
  config.active_storage.service = ENV.fetch('ACTIVE_STORAGE_SERVICE', 'local').to_sym

  # ===============================
  # SSL
  # ===============================
  config.force_ssl = ActiveModel::Type::Boolean.new.cast(
    ENV.fetch('FORCE_SSL', false)
  )

  # ===============================
  # LOG
  # ===============================
  config.log_level = ENV.fetch('LOG_LEVEL', 'info').to_sym
  config.log_tags  = [:request_id]
  config.log_formatter = ::Logger::Formatter.new

  if ActiveModel::Type::Boolean.new.cast(ENV.fetch('RAILS_LOG_TO_STDOUT', true))
    logger = ActiveSupport::Logger.new($stdout)
    logger.formatter = config.log_formatter
    config.logger = ActiveSupport::TaggedLogging.new(logger)
  else
    config.logger = ActiveSupport::Logger.new(
      Rails.root.join("log/#{Rails.env}.log"),
      1,
      ENV.fetch('LOG_SIZE', '1024').to_i.megabytes
    )
  end

  # ===============================
  # CACHE — PARTE CRÍTICA
  # ===============================
  config.cache_store = :redis_cache_store, {
    url: ENV.fetch('CACHE_REDIS_URL'),
    connect_timeout: 5,
    read_timeout: 5,
    write_timeout: 5,
    reconnect_attempts: 1,
    error_handler: -> (method:, returning:, exception:) {
      Rails.logger.error(
        "[Redis] #{method} failed: #{exception.class} #{exception.message}"
      )
    }
  }

  # ===============================
  # Jobs / Sidekiq
  # ===============================
  config.active_job.queue_adapter = :sidekiq

  # ===============================
  # I18n
  # ===============================
  config.i18n.fallbacks = [I18n.default_locale]

  # ===============================
  # Deprecation
  # ===============================
  config.active_support.deprecation = :notify

  # ===============================
  # Active Record
  # ===============================
  config.active_record.dump_schema_after_migration = false

  # ===============================
  # Mailer
  # ===============================
  config.action_mailer.perform_caching = false

  # ===============================
  # Action Mailbox
  # ===============================
  config.action_mailbox.ingress =
    ENV.fetch('RAILS_INBOUND_EMAIL_SERVICE', 'relay').to_sym

  # ===============================
  # URLs
  # ===============================
  Rails.application.routes.default_url_options = {
    host: ENV['FRONTEND_URL']
  }
end

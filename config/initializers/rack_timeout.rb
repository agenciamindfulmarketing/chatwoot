require 'rack-timeout'

Rails.application.config.middleware.insert_before Rack::Runtime, Rack::Timeout, service_timeout: 60

# Reduz ruído de log
Rails.application.config.after_initialize do
  Rack::Timeout::Logger.level = Logger::ERROR
end

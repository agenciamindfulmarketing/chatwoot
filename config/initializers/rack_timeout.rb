require 'rack-timeout'

# Tempo máximo da requisição (em segundos)
Rack::Timeout.timeout = 60

# Reduz ruído de log
Rails.application.config.after_initialize do
  Rack::Timeout::Logger.level = Logger::ERROR
end

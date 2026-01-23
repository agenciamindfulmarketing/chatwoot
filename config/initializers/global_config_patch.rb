# Evita fallback pesado ao banco quando Redis não está quente
module GlobalConfig
  class << self
    alias_method :original_db_fallback, :db_fallback

    def db_fallback(*args)
      Rails.logger.warn '[GlobalConfig] db_fallback bloqueado para evitar timeout'
      {}
    end
  end
end

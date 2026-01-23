module SwitchLocale
  extend ActiveSupport::Concern

  included do
    before_action :switch_locale, unless: :installation_flow?
  end

  private

  def installation_flow?
    controller_path.start_with?('installation/')
  end

  def switch_locale(&block)
    locale = params[:locale]
    locale ||= locale_from_user
    locale ||= locale_from_custom_domain
    locale ||= ENV['DEFAULT_LOCALE']

    set_locale(locale, &block)
  end

  def switch_locale_using_account_locale(&block)
    locale = locale_from_user
    locale ||= locale_from_account(@current_account)

    set_locale(locale, &block)
  end

  # 🔒 DESATIVADO POR ENV (evita timeout em produção)
  def locale_from_custom_domain
    return if ENV['DISABLE_CUSTOM_DOMAIN_LOCALE'] == 'true'
    return if params[:locale]

    domain = request.host
    return if DomainHelper.chatwoot_domain?(domain)

    portal = Portal.find_by(custom_domain: domain)
    return unless portal

    portal.default_locale
  end

  def locale_from_user
    return unless @user

    @user.ui_settings&.dig('locale')
  end

  def locale_from_account(account)
    return unless account

    account.locale
  end

  def set_locale(locale)
  I18n.locale = validate_and_get_locale(locale)
  end

  def validate_and_get_locale(locale)
    return I18n.default_locale.to_s if locale.blank?

    available_locales = I18n.available_locales.map(&:to_s)
    base_locale = locale.split('_').first

    return locale if available_locales.include?(locale)
    return base_locale if available_locales.include?(base_locale)

    I18n.default_locale.to_s
  end
end

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
    # Priority is for locale set in query string (mostly for widget/from js sdk)
    locale ||= params[:locale]

    # Use the user's locale if available
    locale ||= locale_from_user

    # Use the locale from a custom domain if applicable
    locale ||= locale_from_custom_domain

    # fallback to DEFAULT_LOCALE env
    locale ||= ENV.fetch('DEFAULT_LOCALE', nil)

    set_locale(locale, &block)
  end

  def switch_locale_using_account_locale(&block)
    locale = locale_from_user
    locale ||= locale_from_account(@current_account)

    set_locale(locale, &block)
  end

  def locale_from_custom_domain
    return if params[:locale]

    domain = request.host
    return if DomainHelper.chatwoot_domain?(domain)

    @portal = Portal.find_by(custom_domain: domain)
    return unless @portal

    @portal.default_locale
  end

  def locale_from_user
    return unless @user

    @user.ui_settings&.dig('locale')
  end

  def set_locale(locale, &block)
    safe_locale = validate_and_get_locale(locale)
    I18n.with_locale(safe_locale, &block)
  end

  def validate_and_get_locale(locale)
    return I18n.default_locale.to_s if locale.blank?

    available_locales = I18n.available_locales.map(&:to_s)
    locale_without_variant = locale.split('_')[0]

    if available_locales.include?(locale)
      locale
    elsif available_locales.include?(locale_without_variant)
      locale_without_variant
    else
      I18n.default_locale.to_s
    end
  end

  def locale_from_account(account)
    return unless account

    account.locale
  end
end


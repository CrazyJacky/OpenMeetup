# encoding: UTF-8

class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :set_locale, :set_domain, :copy_flash_to_cookie
  helper_method :current_city, :current_language, :current_user
  helper LaterDude::CalendarHelper

  auto_user

  rescue_from CanCan::AccessDenied do |exception|
    url = @group
    url ||= root_url
    flash[:alert] = 'Nincsen megfelelő jogosultságod ehhez!'
    redirect_to url
  end

private

  def copy_flash_to_cookie
    # cookies[:flash_notice] = URI.escape(flash[:notice]).to_json if flash[:notice]
    # cookies[:flash_alert] = URI.escape(flash[:alert]).to_json if flash[:alert]
    # flash.clear
  end

  def current_locale
    session[:locale] = if params[:locale]
      params[:locale]
    elsif current_user
      current_user.locale
    elsif Settings.default_language
      Settings.default_language
    elsif not session[:locale]
      tr8n_user_preffered_locale
    end
    current_user.update_attributes :locale => session[:locale] if current_user and not current_user.locale == session[:locale]
    session[:locale]
  end
  helper_method :current_locale

  def create_activity(item)
    Activity.create :activable_type => item.class.name, :activable_id => item.id
  end

  def current_language
    @current_language ||= Language.find_by_code(I18n.locale)
  end

  def store_location
    session[:return_to] = request.fullpath
  end

  def authenticate
    unless current_user
      store_location
      redirect_to sign_in_url
    end
  end

  def redirect_back_or_default(default)
    redirect_to session[:return_to] || default
    session[:return_to] = nil
  end

  def current_city
    return @current_city if defined?(@current_city)
    @current_city = current_user.andand.city
  end

  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.record
  end
  helper_method :current_user

  def extract_locale_from_accept_language_header
    request.env['HTTP_ACCEPT_LANGUAGE'].andand.scan(/^[a-z]{2}/).andand.first
  end

  def set_city
    if not Settings.standalone and current_user and not current_city
      store_location
      redirect_to edit_city_user_path(current_user)
    end
  end

  def set_domain
#    host = request.env['HTTP_HOST'].split(':').first
#    request.env['rack.session.options'][:domain] = ".#{host}"
  end

  def set_locale
    I18n.locale = current_locale
  end
end

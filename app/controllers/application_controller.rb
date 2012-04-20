class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :current_user_session, :current_user, :require_user, :require_no_user, :current_user_marker

  private

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to('/user_sessions/new', :alert => exception.message)
  end

  def global_request_logging
    if current_user_session
      Rails.logger.info "Admin [#{current_user.id}] : Request  #{request.method.inspect} to #{request.url.inspect} from #{request.remote_ip.inspect}."
    else
      Rails.logger.info "Request  #{request.method.inspect} to #{request.url.inspect} from #{request.remote_ip.inspect}."
    end

    return true
  end

  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.record
  end

  def current_user_marker
    first_trial = current_user.trials.first.id rescue "nt"
    first_site = current_user.site.first rescue  "ns"
    "#{current_user.id}-#{first_trial}-#{first_site}"
  end

  def require_user
    unless current_user
      store_location
      if current_user_session && current_user_session.stale?
        flash[:alert] = "Your Session has timed out: Please login"
      else
        flash[:alert] = "You must be logged in to access this page"
      end
      redirect_to new_user_session_url
      return false
    end

  end

  def require_no_user
    if current_user
      store_location
      flash[:alert] = "You must be logged out to access this page"

      redirect_to schedule_path

      return false
    end
  end

  def store_location
    session[:return_to] = request.fullpath
  end

  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end

  def sanitize_phone_number number
    number.gsub /[\(,\), , -]/, ""
  end

end

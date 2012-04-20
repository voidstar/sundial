class UserSession < Authlogic::Session::Base

  logout_on_timeout true
  generalize_credentials_error_messages "Email or Password is invalid"

  # How many consecutive login attempts to allow
  failed_login_ban_for 15.minutes
  consecutive_failed_logins_limit 3

  def to_key
     new_record? ? nil : [ self.send(self.class.primary_key) ]
  end

  def persisted?
    false
  end
end

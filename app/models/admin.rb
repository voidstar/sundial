class Admin < ActiveRecord::Base

  # ------------------------------------------------------------------------------------------------
  # Authentication plugin
  # ------------------------------------------------------------------------------------------------
  acts_as_authentic do |a|
    a.login_field = 'email'
    a.validate_login_field = true
    # a.merge_validates_format_of_email_field_options :unless => Proc.new { |u| u.has_role? :participant }
    #a.merge_validates_format_of_login_field_options :unless => Proc.new { |u| u.has_role? :participant }

    # When login session times out
    a.logged_in_timeout = 5.minutes

    # How long before perishible_token expires
    a.perishable_token_valid_for = 24.hours

    # Handle password verification
    a.merge_validates_length_of_password_field_options({:minimum => 8,
                                                        :too_short => "Your password must have 8 characters or more.",
                                                        :maximum => 20,
                                                        :too_long => "Your password cannot have more than 20 characters"
                                                        })
  end

end

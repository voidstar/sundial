require 'ostruct'
require ::Rails.root.to_s + "/config/config"

######################################################################################################
# DATETIME FORMATS CONFIG
######################################################################################################
Sundial::Config.date_format = '%m-%d-%Y'
Sundial::Config.datetime_format = '%m-%d-%Y %I:%M %p'
Sundial::Config.datetime_zone_format = '%m-%d-%Y %I:%M %p %z'
Sundial::Config.java_simpledate_zone_format = 'MM-dd-yy h:m a Z'
Sundial::Config.java_simpledate_format = 'MM-dd-yy h:m a'
Sundial::Config.default_time_zone = "Pacific Time (US & Canada)"

Sundial::Config.verify_ssl_cert = true

######################################################################################################
# ENVIRONMENT OVERRIDES
######################################################################################################
if "production".eql?(Rails.env)
  require ::Rails.root.to_s + "/config/config_production"
elsif "development".eql?(Rails.env)
  require ::Rails.root.to_s + "/config/config_development"
end
require ::Rails.root.to_s + "/config/config_user" if File.exists?(::Rails.root.to_s + "/config/config_user")




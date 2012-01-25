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




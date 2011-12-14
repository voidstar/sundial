require 'ostruct'
require 'log4r'
require 'log4r/yamlconfigurator'
require 'log4r/outputter/datefileoutputter'
require 'log4r/outputter/emailoutputter'
require 'log4r/outputter/fileoutputter'

y_cfg = Log4r::YamlConfigurator

#---------------------------------------------------
#---------------------------------------------------
y_cfg['RAILS_ROOT'] = Rails.root.to_s
y_cfg['RAILS_ENV'] = Rails.env

# load the YAML file with this
y_cfg.load_yaml_file(Rails.root.to_s + '/config/log4r.yml')

Rails.logger = Log4r::Logger['default']
Rails.logger.level = (Rails.env == 'development' ? Log4r::DEBUG : Log4r::INFO)
# ActiveRecord::Base.logger = Log4r::Logger['sql']


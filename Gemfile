source 'http://rubygems.org'

gem 'rails', '3.0.7'

gem 'rake'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

platforms :ruby do
  gem 'mysql2'
end

platforms :jruby do
  gem 'activerecord-jdbcmysql-adapter'
  gem 'jdbc-mysql'
  gem "jdbc-sqlite3"
  gem "jruby-openssl"
  # gem "ffi-ncurses"
end

gem 'haml' # View Parsing
gem 'haml-rails'
gem 'sass' # Stylesheet parsing
gem 'jquery-rails'


#Common Application Gems
gem 'authlogic' # Authentication
gem 'cancan', "<= 1.6.5" # Authorization
gem 'role_model' # User Roles
gem 'aasm', '>=2.2.0' # State machine

# Utility Gems
gem 'pry'
gem 'pry-doc'
gem 'pry-rails'
gem 'log4r'

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'
#  gem 'capistrano-ext'

# To use debugger (ruby-debug for Ruby 1.8.7+, ruby-debug19 for Ruby 1.9.2+)
# gem 'ruby-debug'
# gem 'ruby-debug19', :require => 'ruby-debug'

# Bundle the extra gems:
# gem 'bj'
# gem 'nokogiri'
# gem 'sqlite3-ruby', :require => 'sqlite3'
# gem 'aws-s3', :require => 'aws/s3'

# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:
# group :development, :test do
#   gem 'webrat'
# end
group :development, :test do
  gem 'rspec'
  gem 'rspec-rails'

  # Deploy with Capistrano
  gem 'capistrano'
  gem 'capistrano-ext'

end

group :test do
  gem 'factory_girl'
end


require "bundler/capistrano"
require 'capistrano/ext/multistage'

set :keep_releases, 2
set :stages, %w[sundial]

# Include recipes from lib
Dir['lib/recipes/*.rb'].each { |recipe| load(recipe) }

# set :bundle_dir, ""
# set :bundle_flags, ""
# set :bundle_flags, "--deployment --quiet --binstubs --shebang ruby-local-exec"
set :bundle_flags, "--deployment --quiet --binstubs"

set :application, "sundial"

# SCM
set :scm, :git
set :repository,  "git@github.com:voidstar/#{application}.git"
set :branch, "master"
set :git_shallow_clone, 1

set :rails_env, "production"
set :bundle_exec, "RAILS_ENV=#{rails_env} bundle exec"

# Passenger Setup for Rails
namespace :deploy do
   task :start do ; end
   task :stop do ; end

   # before "deploy:update_code", "torquebox:undeploy"

   # Order is honored
   after "deploy:update_code", :link_production_db
   after "deploy:symlink", "torquebox:deploy"
   after "deploy", "deploy:cleanup"
  # TODO: Add Jammit, Uglifier, Closuer, etc
end

# database.yml task
desc "Link in the production database.yml"
task :link_production_db do
  run "ln -nfs #{deploy_to}/shared/config/database.yml #{release_path}/config/database.yml"
end




set :appdir, "/srv/#{application}"
set :location, "nandinahealth.com"
set :domain, "nandinahealth.com"
set :user, "nandinaportal"

set :default_environment, {
    'PATH' => "/home/#{user}/.rbenv/shims:/home/#{user}/.rbenv/bin:$PATH"
}


#set :deploy_via, :remote_cache
set :deploy_via, :export
set :deploy_to, appdir
set :port, 2552

ssh_options[:forward_agent] = true

set :use_sudo, false

role :web, domain                          # Your HTTP server, Apache/etc
role :app, domain                          # This may be the same as your `Web` server
role :db,  domain, :primary => true # This is where Rails migrations will run
# role :db,  "your slave db-server here"

set :torquebox_exec, "/home/#{user}/.rbenv/shims/torquebox"

namespace :torquebox do

  desc "Deploy Sundial application to torquebox"
  task :deploy, roles => :app, :except => {:no_release => true} do
    run "cd #{current_path} && #{torquebox_exec} deploy ."
  end

  task :start, roles => :app, :except => {:no_release => true} do
    run "cd #{current_path} && #{torquebox_exec} start -b 0.0.0.0"
  end

  task :stop, roles => :app, :except => {:no_release => true} do
    run "cd #{current_path} && #{torquebox_exec} stop"
  end

  task :restart, roles => :app, :except => {:no_release => true} do
    stop
    sleep 5
    start
  end

end

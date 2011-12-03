
set :appdir, "/home/brett/dev/projects/#{application}"
set :location, "localhost:3000"
set :domain, "127.0.0.1"
set :user, "brett"

set :default_environment, {
    'PATH' => "/home/#{user}/.rbenv/shims:/home/#{user}/.rbenv/bin:$PATH"
}

role :web, domain                          # Your HTTP server, Apache/etc
role :app, domain                          # This may be the same as your `Web` server
role :db,  domain, :primary => true # This is where Rails migrations will run
# role :db,  "your slave db-server here"


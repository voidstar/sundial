namespace(:tail) do
  task :start, :roles => :app do
     run <<-CMD
       cd #{current_path} &&
       tail -F log/*.log 
     CMD
  end 
end


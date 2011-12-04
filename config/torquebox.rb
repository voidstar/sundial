TorqueBox.configure do

  web do
    context "/sundial"
    static "public"
  end

  environment do
    RAILS_ENV "production"
  end

end

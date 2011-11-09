class Schedule < ActiveRecord::Base

  validates_presence_of :name, :group, :cron, :callback_url
  validates_uniqueness_of :name, :scope => :group


  class << self

    # prevent bulk insert save build method
    def build(params)
      s = Schedule.new
      s.name = params[:name]
      s.group = params[:group]
      s.cron = params[:cron]
      s.time_zone = params[:time_zone]
      s.callback_url = params[:callback_url]
      return s
    end

  end

end

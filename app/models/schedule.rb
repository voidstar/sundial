class Schedule < ActiveRecord::Base

  validates_presence_of :name, :group, :callback_url
  validates_presence_of :cron, :if => Proc.new {|s| s.timing.nil? }
  validates_presence_of :timing, :if => Proc.new {|s| s.cron.nil? }
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
      s.callback_params = params[:callback_params]
      s.timing = params[:timing]
      return s
    end

  end

end

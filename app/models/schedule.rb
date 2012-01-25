require 'java'

java_import java.util.TimeZone
# java_import java.text.SimpleDateFormat
# java_import java.text.DateFormat

class Schedule < ActiveRecord::Base

  # ------------------------------------------------------------------------------------------------
  # Validations
  # ------------------------------------------------------------------------------------------------

  validates_presence_of :name, :group, :callback_url
  validates_presence_of :cron, :if => Proc.new {|s| s.timing.nil? }
  validates_presence_of :timing, :if => Proc.new {|s| s.cron.nil? }
  validates_presence_of :threshold, :if => Proc.new {|s| s.cron.nil?}
  validates_uniqueness_of :name, :scope => :group

  #-----------------------------------------------------------------------------------------------
  # State Machine plugin
  #-----------------------------------------------------------------------------------------------
  include AASM

  aasm_column :state
  aasm_initial_state :new

  aasm_state :new
  aasm_state :finished
  aasm_state :finished_after_threshold
  aasm_state :finish_failed

  aasm_event :finish do
    transitions :to => :finished, :from => [:new]
  end

  aasm_event :finish_after_threshold do
   transitions :to => :finished_after_threshold, :from => [:new]
  end

  aasm_event :fail_finish do
    transitions :to => :finish_failed, :from => [:new, :finish, :finish_after_threshold]
  end

  @logger = nil

  def logger
    @logger ||= Log4r::Logger.new('Scheduler::Schedule')
  end

  # Determines whether a schedule is within timing threshold at the moment this method is called.
  # The threshold calculation is performed in time zone of the schedule instance.
  def within_threshold?
    return true
    dateTime = DateTime.strptime(self.timing, Sundial::Config.datetime_format)

    # s_timing_threshold = dateTime.in_time_zone(self.time_zone).advance(:seconds => self.threshold)
    s_timing_threshold = dateTime.advance(:seconds => self.threshold)

    # now_in_target_tz = DateTime.now.in_time_zone(self.time_zone)
    now_in_target_tz = DateTime.now

    logger.info("Checking schedule [#{self.id}] timing threshold [#{s_timing_threshold}] using current time in "\
      "schedule's time zone: #{now_in_target_tz}")

    return now_in_target_tz <= s_timing_threshold
  end

  class << self

    # prevent bulk insert save build method
    def build(params)
      s = Schedule.new
      s.name = params[:name]
      s.group = params[:group]
      s.cron = params[:cron]
      s.time_zone = CGI::unescapeHTML(params[:time_zone]) rescue nil
      s.callback_url = params[:callback_url]
      s.callback_params = params[:callback_params]
      s.timing = params[:timing]
      s.threshold = params[:threshold]
      return s
    end

  end
end

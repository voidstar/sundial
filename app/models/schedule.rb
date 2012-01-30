require 'java'

java_import java.util.TimeZone
# java_import java.text.SimpleDateFormat
# java_import java.text.DateFormat

class Schedule < ActiveRecord::Base

  # ------------------------------------------------------------------------------------------------
  # Security Details
  # ------------------------------------------------------------------------------------------------

  # Define whitelist to protect against mass assignment
  # These attributes may be assigned by a hash, but any not listed
  # here must be set explicitly by mutator methods
  attr_accessible :name, :group, :cron, :time_zone, :callback_url, :callback_params, :timing, :threshold

  # ------------------------------------------------------------------------------------------------
  # Validations
  # ------------------------------------------------------------------------------------------------

  validates_presence_of :name, :group, :callback_url
  validates_presence_of :cron, :if => Proc.new {|s| s.timing.nil? }
  validates_presence_of :timing, :if => Proc.new {|s| s.cron.nil? }
  validates_presence_of :threshold, :if => Proc.new {|s| s.cron.nil?}
  validates_uniqueness_of :name, :scope => :group

  # ------------------------------------------------------------------------------------------------
  # Data cleansing
  # ------------------------------------------------------------------------------------------------
  before_validation :sanitize_time_zone

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

  def scheduled_time_with_zone
    tz = time_zone.nil? \
      ? ActiveSupport::TimeZone[Sundial::Config.default_time_zone] :
        ActiveSupport::TimeZone[time_zone]

    offset = tz.formatted_offset
    DateTime.strptime("#{timing} #{offset}", Sundial::Config.datetime_zone_format)
  end

  def scheduled_time_local
    scheduled_time_with_zone.in_time_zone(Sundial::Config.default_time_zone)
  end

  # Determines whether a schedule is within timing threshold at the moment this method is called.
  # The threshold calculation is performed in time zone of the schedule instance.
  def within_threshold?

    s_timing_threshold = scheduled_time_local.in(self.threshold)
    now_in_target_tz = DateTime.now.in_time_zone(Sundial::Config.default_time_zone)

    logger.info("Checking schedule [#{self.id}] timing threshold [#{s_timing_threshold}] using current time in "\
      "schedule's time zone: #{now_in_target_tz}")

    return now_in_target_tz <= s_timing_threshold
  end

  private

  def sanitize_time_zone
    if attribute_present?("time_zone") && time_zone.is_a?(String)
      self.time_zone = CGI::unescapeHTML(time_zone)
    end
  end

end

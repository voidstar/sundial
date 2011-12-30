require 'quartz/job_detail'

java_import java.util.TimeZone
java_import java.text.SimpleDateFormat
java_import java.text.DateFormat

# Quartz Scheduler API Adapter
# Wraps Quartz Scheduler DSL for Jobs and Triggers
module Quartz
  module Scheduler

    @@logger = nil

    # Returns Logger
    def logger
      @@logger ||= Log4r::Logger.new("Scheduler::Quartz::Scheduler")
    end

    def self.included(base)
      base.class_eval <<-EOF
        include InstanceMethods
        extend ClassMethods
        include Singleton
      EOF
    end

    module ClassMethods
      def build_schedule(schedule)
        instance.build_schedule(schedule)
      end
    end

    module InstanceMethods

      # @param schedule [Object]
      def build_schedule(schedule)

        unless schedule.class.to_s == "Schedule"
          raise "Cannot build a schedule in Quartz Scheduler without schedule object"
        end

        if schedule.cron.nil? && schedule.timing.nil?
          raise "Cannot process Schedule object without cron expression or timing date string"
        end

        # Determine time zone for cron.  Default to Pacific
        # zone = Java::Util::TimeZone.new(schedule.time_zone ||= "America/Los_Angeles")

        RemoteJob.to_java(org.quartz.Job)
        job_detail = Quartz::JobDetail.new(schedule.name, schedule.group, RemoteJob.new)
        job_detail.schedule_id = schedule.id

        trigger = nil

        unless schedule.cron.nil?
          logger.info("Scheduling cron [#{schedule.cron}] for recurring schedule [#{schedule.id}]")
          trigger = TriggerBuilder.newTrigger()\
          .withIdentity("#{schedule.name}_trigger", schedule.group)\
          .withSchedule(CronScheduleBuilder.cronSchedule(schedule.cron))\
          .build()
        else
          s_utc_offset_sec = ActiveSupport::TimeZone.find_tzinfo(schedule.time_zone).current_period.offset.utc_total_offset
          s_utc_offset_hhmm = ActiveSupport::TimeZone.seconds_to_utc_offset(s_utc_offset_sec, false)

          logger.info("converted schedule#time_zone format [#{schedule.time_zone}] to UTC offset in HHMM format "\
            "[#{s_utc_offset_hhmm}] for schedule [#{schedule.id}]")

          formatter = SimpleDateFormat.new(Sundial::Config.java_simpledate_zone_format)
          s_dtz = schedule.timing + " #{s_utc_offset_hhmm}"
          startAtDate = formatter.parse(s_dtz)

          logger.info("Building trigger using local datetime [#{startAtDate}] for non-recurring schedule [#{schedule.id}] "\
            "with datetime [#{s_dtz}")

          trigger = TriggerBuilder.newTrigger()\
          .withIdentity("#{schedule.name}_trigger", schedule.group)\
          .startAt(startAtDate)\
          .withSchedule(SimpleScheduleBuilder.simpleSchedule().withRepeatCount(0))\
          .build()
        end

        scheduler.set_job_factory(JobFactory.instance)
        scheduler.schedule_job(job_detail, trigger)
      end

      def scheduler_factory
        @scheduler_factor ||= StdSchedulerFactory.new
      end

      def scheduler
        scheduler_factory.get_scheduler
      end

      def job_factory
        Quartz::JobFactory.instance
      end

      def run
        scheduler.start
      end
    end

    class QuartzSchedulerError < StandardError; end
  end
end

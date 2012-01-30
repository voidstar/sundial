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

        RemoteJob.to_java(org.quartz.Job)
        job_detail = Quartz::JobDetail.new(schedule.name, schedule.group, RemoteJob.new)
        job_detail.schedule_id = schedule.id

        trigger = build_with_trigger(schedule, TriggerBuilder.newTrigger())

        scheduler.set_job_factory(JobFactory.instance)
        scheduler.schedule_job(job_detail, trigger)
      end

      # Update the Schedule using jobKey and schedule with updated attributes
      def update_schedule_trigger(schedule)
        oldTrigger = scheduler.getTrigger(TriggerKey.new("#{schedule.name}_trigger", schedule.group))

        # obtain a builder that would produce the trigger
        tb = oldTrigger.getTriggerBuilder()

        # update the schedule associated with the builder, and build the new trigger
        # (other builder methods could be called, to change the trigger in any desired way)
        newTrigger = build_with_trigger(schedule, tb)

        scheduler.rescheduleJob(oldTrigger.getKey(), newTrigger)
      end

      # Build Trigger from Schedule and Trigger Builder
      def build_with_trigger(schedule, trigger)

        # If we have timing and not cron, then send single trigger
        if schedule.cron.nil? && !schedule.timing.nil?
          formatter = SimpleDateFormat.new(Sundial::Config.java_simpledate_zone_format)
          startAtDate = formatter.parse(schedule.scheduled_time_local.strftime(Sundial::Config.datetime_zone_format))

          logger.info("Building trigger using local datetime [#{startAtDate}] for " +
                          "non-recurring schedule [#{schedule.id}] with timing [#{schedule.timing}")

          return trigger.withIdentity("#{schedule.name}_trigger", schedule.group)\
          .startAt(startAtDate)\
          .withSchedule(SimpleScheduleBuilder.simpleSchedule().withRepeatCount(0))\
          .build()
        else
          logger.info("Scheduling cron [#{schedule.cron}] for recurring schedule [#{schedule.id}]")
          return trigger.withIdentity("#{schedule.name}_trigger", schedule.group)\
          .withSchedule(CronScheduleBuilder.cronSchedule(schedule.cron))\
          .build()
        end

      end

      def remove_schedule(jobKey)
        scheduler.deleteJob(jobKey)
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

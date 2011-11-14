require 'quartz/job_detail'

java_import java.util.TimeZone

# Quartz Scheduler API Adapter
# Wraps Quartz Scheduler DSL for Jobs and Triggers
module Quartz
  module Scheduler

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

      def build_schedule(schedule)

        unless schedule.class.to_s == "Schedule"
          raise "Cannot build a schedule in Quartz Scheduler without schedule object"
        end

        unless schedule.cron
          raise "Cannot process Schedule object without cron expression"
        end

        # Determine time zone for cron.  Default to Pacific
        # zone = Java::Util::TimeZone.new(schedule.time_zone ||= "America/Los_Angeles")

        RemoteJob.to_java(org.quartz.Job)
        job_detail = Quartz::JobDetail.new(schedule.name, schedule.group, RemoteJob.new)
        job_detail.schedule_id = schedule.id

        trigger = TriggerBuilder.newTrigger()\
        .withIdentity("#{schedule.name}_trigger", schedule.group)\
        .withSchedule(CronScheduleBuilder.cronSchedule(schedule.cron))\
        .build();

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

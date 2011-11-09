require 'java'
import org.quartz.Job
import org.quartz.JobExecutionContext
import org.quartz.JobExecutionException

module Scheduler
  class Job
    include org.quartz.Job

    def initialize(); end

    def execute( context )
      begin
        execute_task( context )
      rescue Exception => e
        raise QuartzJobError.new(e)
      end
    end

    protected

    def execute_task( context )
      raise "Subclass must implement the execute_task method"
    end

  end

  class QuartzJobError < StandardError ; end
end
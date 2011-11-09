require 'java'
java_import org.quartz.Job
java_import import org.quartz.JobExecutionContext
java_import import org.quartz.JobExecutionException

class RemoteJob
  include org.quartz.Job

  def initialize()
    ;
  end

  def execute(context)
    begin
      Rails.logger.info "DID I REACH THIS?"
      execute_task(context)
    rescue Exception => e
      raise StandardError.new(e)
    end
  end

  protected

  def execute_task(context)
    Rails.logger.info "JOB IS FINALLY EXECUTING"
  end

end


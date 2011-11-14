require 'java'
require 'net/http'

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
      execute_task(context)
    rescue Exception => e
      raise StandardError.new(e)
    end
  end

  protected

  def execute_task(context)
    detail = context.get_job_detail
    Rails.logger.info "Executing schedule with ID :  #{detail.schedule_id}"
    schedule = Schedule.find_by_id(detail.schedule_id)

    response = nil
    begin
      url = URI.parse(schedule.callback_url)
      req = Net::HTTP::Post.new(url.request_uri)

      Rails.logger.info "Callback Params : #{schedule.callback_params}"
      unless schedule.callback_params.nil?
        params = ActiveSupport::JSON.decode(schedule.callback_params)
        req.form_data = params
      end

      Net::HTTP.start(url.host, url.port) { |http|
        http.read_timeout = 120
        response = http.request(req)
      }
      status = response['status']
      Rails.logger.info response.body
    rescue => e
      Rails.logger.error "Exception: #{e.message}"
    end
  end

end


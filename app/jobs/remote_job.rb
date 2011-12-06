require 'java'
require 'net/http'
require 'net/https'

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
      Rails.logger.error "CAUGHT EXCEPTION : #{e.message}"
    end
  end

  def test schedule

    response = nil
    begin
      url = URI.parse(schedule.callback_url)
      req = Net::HTTP::Post.new(url.request_uri)

      Rails.logger.info "Callback Params : #{schedule.callback_params}"
      unless schedule.callback_params.nil?
        params = ActiveSupport::JSON.decode(schedule.callback_params)
        req.form_data = params
      end

      http = Net::HTTP.new(url.host, url.port)
      http.read_timeout = 30
      if url.scheme == "https"
        http.use_ssl = true
        # http.verify_mode = OpenSSL::SSL::VERIFY_PEER
        # TODO: see the following url to improve security :
        #   http://www.rubyinside.com/how-to-cure-nethttps-risky-default-https-behavior-4010.html
      end
      response = http.request(req)
      status = response['status']
      Rails.logger.info response.body
    rescue => e
      Rails.logger.error "Exception: #{e.message}"
    end

    response

  end

  protected

  def execute_task(context)
    detail = context.get_job_detail
    Rails.logger.info "Executing schedule with ID :  #{detail.schedule_id}"
    schedule = Schedule.find_by_id(detail.schedule_id)

    Rails.logger.info "Processing schedule with id : #{detail.schedule_id}"
    response = nil
    begin
      url = URI.parse(schedule.callback_url)
      req = Net::HTTP::Post.new(url.request_uri)

      Rails.logger.info "Callback Params : #{schedule.callback_params}"
      unless schedule.callback_params.nil?
        params = ActiveSupport::JSON.decode(schedule.callback_params)
        req.form_data = params
      end

      http = Net::HTTP.new(url.host, url.port)
      http.read_timeout = 30
      if url.scheme == "https"
        http.use_ssl = true
        # http.verify_mode = OpenSSL::SSL::VERIFY_PEER
        # TODO: see the following url to improve security :
        #   http://www.rubyinside.com/how-to-cure-nethttps-risky-default-https-behavior-4010.html
      end
      response = http.request(req)
      status = response['status']
      Rails.logger.info response.body
    rescue => e
      Rails.logger.error "Exception: #{e.message}"
    end
  end

end


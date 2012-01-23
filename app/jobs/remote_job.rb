require 'java'
require 'net/http'
require 'net/https'

java_import org.quartz.Job
java_import import org.quartz.JobExecutionContext
java_import import org.quartz.JobExecutionException

class RemoteJob
  include org.quartz.Job

  @logger = nil

  def logger
    @logger ||= Log4r::Logger.new('Scheduler::RemoteJob')
  end

  def initialize; end

  def execute(context)
    begin
      execute_task(context)
    rescue Exception => e
      logger.error("CAUGHT EXCEPTION : #{e.message}")
    end
  end

  def test(schedule)

    response = nil
    begin
      url = URI.parse(schedule.callback_url)
      req = Net::HTTP::Post.new(url.request_uri)

      logger.info("Schedule [#{schedule.id}] with callback params [#{schedule.callback_params}]")
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
      logger.info("Schedule [#{schedule.id}] with response [#{response.body}]")
    rescue => e
      logger.error("Schedule [#{schedule.id}] raised exception: #{e.message}")
    end

    response

  end

  protected

  def execute_task(context)
    detail = context.get_job_detail
    logger.info("Executing task for schedule [#{detail.schedule_id}]")
    schedule = Schedule.find_by_id(detail.schedule_id)

    logger.info("Found schedule [#{schedule.id}] so will begin processing....")
    response = nil
    begin
      logger.warn("Schedule cron : #{schedule.cron}")
      if schedule.cron.nil? && !schedule.within_threshold?
        logger.warn("Didn't invoke callback for schedule [#{schedule.id}] as its now past the schedule's callback window")
        schedule.finish_after_threshold!
        return
      end
      url = URI.parse(schedule.callback_url)
      req = Net::HTTP::Post.new(url.request_uri)

      logger.info("Schedule [#{schedule.id}] using callback params [#{schedule.callback_params}]")
      unless schedule.callback_params.nil?
        params = ActiveSupport::JSON.decode(schedule.callback_params)
        req.form_data = params
      end

      http = Net::HTTP.new(url.host, url.port)
      http.read_timeout = 30
      if url.scheme == "https"
        logger.info("Schedule [#{schedule.id}] using HTTPS to connect to remote client")
        http.use_ssl = true
        # http.verify_mode = OpenSSL::SSL::VERIFY_PEER
        # TODO: see the following url to improve security :
        #   http://www.rubyinside.com/how-to-cure-nethttps-risky-default-https-behavior-4010.html
      end
      response = http.request(req)
      status = response['status']
      logger.info("Schedule [#{schedule.id}] received response: #{response.body}")
      schedule.finish! if schedule.cron.nil? # Hack for schedule type - TODO
    rescue => e
      logger.error("Schedule [#{schedule.id}] raised exception: #{e.message}")
      schedule.fail_finish! if schedule.cron.nil? # Hack for schedule type - TODO
    end
  end
end



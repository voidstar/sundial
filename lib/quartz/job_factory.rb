
class JobFactory

  include Singleton
  include org.quartz.spi.JobFactory
  attr_accessor :jobs

  def initialize
    @jobs||={}
  end

  def newJob(bundle, scheduler)
    bundle.get_job_detail.job
  end

end

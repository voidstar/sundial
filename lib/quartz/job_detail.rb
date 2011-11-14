module Quartz
  class JobDetail < Java::OrgQuartzImpl::JobDetailImpl
    attr_accessor :job
    attr_accessor :schedule_id

    def initialize(name,group,job)
      super()
      set_name name
      set_group group
      set_job_class job.class.java_class
      @job = job
    end

    def validate
    end
  end
end

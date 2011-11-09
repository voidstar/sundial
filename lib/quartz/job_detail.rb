module Quartz
  class JobDetail < Java::OrgQuartzImpl::JobDetailImpl
    attr_accessor :job

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

Dir.glob(File.join(Rails.root.to_s, '/lib/java/*.jar')).each {|f| require f }

libdir = Rails.root.to_s + "/lib"
$LOAD_PATH.unshift(libdir) unless($LOAD_PATH.include?(libdir) || $LOAD_PATH.include?(File.dirname(__FILE__)))

# require 'jobs/configuration'

# Import logging jars required by Quartz
java_import org.apache.log4j.PropertyConfigurator
java_import org.slf4j.Logger
java_import org.slf4j.LoggerFactory

# setup log4j from properties file
# PropertyConfigurator.configure("lib/java/log4j.properties")

# Include Java Classes we know  we'll need

java_import org.quartz.Job
java_import org.quartz.JobKey
java_import org.quartz.JobBuilder
java_import org.quartz.JobDetail
java_import org.quartz.impl.JobDetailImpl

java_import org.quartz.impl.StdSchedulerFactory
java_import org.quartz.SchedulerFactory
java_import org.quartz.SchedulerException
java_import org.quartz.Scheduler

java_import org.quartz.CronTrigger
java_import org.quartz.CronScheduleBuilder
java_import org.quartz.SimpleTrigger
java_import org.quartz.SimpleScheduleBuilder
java_import org.quartz.TriggerBuilder

require 'remote_job_scheduler'

run_quartz = (!ENV['RUN_QUARTZ'].nil? || ENV['RUN_QUARTZ'] == 'true') ? true : false

if run_quartz
  RemoteJobScheduler.instance.run
end



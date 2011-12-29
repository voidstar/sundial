require 'spec_helper'

describe Schedule do

  before do
    @schedule = Schedule.new({:name => 'name',
                              :group => 'groupname',
                              :time_zone => 'Pacific Time (US & Canada)',
                              :callback_url => 'http://someurl.com',
                              :timing => Time.now.to_datetime.strftime(Sundial::Config.datetime_format),
                              :threshold => '60'})
  end

  it "should return false when time of check is after threshold window" do
    past_timing = Time.now - 2.minutes
    @schedule.timing = past_timing.to_datetime.strftime(Sundial::Config.datetime_format)
    @schedule.within_threshold?.should eq false
  end

  it "should return true when time of check is in threshold window" do
    @schedule.within_threshold?.should eq true
  end

  it "should return true when time of check is in threshold window and the schedule is using ActiveSupport friendly time zone name 'Eastern Time (US & Canada)'" do
   @schedule.time_zone = 'Eastern Time (US & Canada)'
   @schedule.timing = Time.now.advance(:hours => 3).to_datetime.strftime(Sundial::Config.datetime_format)
   @schedule.within_threshold?.should eq true
  end

  it "should return true when time of check is in threshold window and the schedule is using ActiveSupport friendly time zone name 'Central Time (US & Canada)'" do
   @schedule.time_zone = 'Central Time (US & Canada)'
   @schedule.timing = Time.now.advance(:hours => 2).to_datetime.strftime(Sundial::Config.datetime_format)
   @schedule.within_threshold?.should eq true
  end

  it "should return true when time of check is in threshold window and the schedule is using ActiveSupport friendly time zone name 'Hawaii'" do
   @schedule.time_zone = 'Hawaii'
   @schedule.timing = Time.now.advance(:hours => -2).to_datetime.strftime(Sundial::Config.datetime_format)
   @schedule.within_threshold?.should eq true
  end

  it "should return true when time of check is in threshold window and the schedule is using TZInfo abbreviation 'HST'" do
   @schedule.time_zone = 'HST'
   @schedule.timing = Time.now.advance(:hours => -2).to_datetime.strftime(Sundial::Config.datetime_format)
   @schedule.within_threshold?.should eq true
  end

  it "should return true when time of check is in threshold window and the schedule is using TZInfo identifier 'America/Phoenix'" do
   @schedule.time_zone = 'America/Phoenix'
   @schedule.timing = Time.now.advance(:hours => 1).to_datetime.strftime(Sundial::Config.datetime_format)
   @schedule.within_threshold?.should eq true
  end

  it "should return true when time of check is in threshold window and the schedule is using ActiveSupport friendly time zone name 'Beijing'" do
   @schedule.time_zone = 'Beijing'
   @schedule.timing = Time.now.advance(:hours => 16).to_datetime.strftime(Sundial::Config.datetime_format)
   @schedule.within_threshold?.should eq true
  end

  it "should return true when time of check is in threshold window and the schedule is using ActiveSupport friendly time zone name 'Brussels'" do
   @schedule.time_zone = 'Brussels'
   @schedule.timing = Time.now.advance(:hours => 9).to_datetime.strftime(Sundial::Config.datetime_format)
   @schedule.within_threshold?.should eq true
  end

end

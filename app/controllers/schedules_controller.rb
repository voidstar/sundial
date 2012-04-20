require 'quartz/scheduler'
require 'remote_job_scheduler'

class SchedulesController < ApplicationController

  before_filter :require_user

  # GET /schedules
  # GET /schedules.xml
  def index
    @schedules = Schedule.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml { render :xml => @schedules }
    end
  end

  # GET /schedules/1
  # GET /schedules/1.xml
  def show
    @schedule = Schedule.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml { render :xml => @schedule }
    end
  end

  # GET /schedules/new
  # GET /schedules/new.xml
  def new
    @schedule = Schedule.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml { render :xml => @schedule }
    end
  end

  # GET /schedules/1/edit
  def edit
    @schedule = Schedule.find(params[:id])
  end

  # POST /schedules
  # POST /schedules.xml
  def create

    # Get schedule json object from parameters
    schedule_params = params[:schedule] ||= {}

    # Find if schedule has been created already
    # find by name and group
    @schedule = Schedule.find_by_name_and_group(schedule_params[:name], schedule_params[:group])

    if @schedule

      # Check to see if the schedule is registered with Quartz (after restart or removal, etc)
      key = JobKey.new(@schedule.name, @schedule.group)
      unless RemoteJobScheduler.instance.scheduler.check_exists(key)
        RemoteJobScheduler.instance.build_schedule(@schedule)
      end

      render :json => {:schedule_id => @schedule.id, :msg => 'schedule already exists'}
    else
      begin
        @schedule = Schedule.new(schedule_params)
      rescue => e
        Rails.logger.error "Could not create schedule : #{e.message}"
        render :json => {:error => e.message}
        return
      end

      if @schedule.save
        begin
          RemoteJobScheduler.instance.build_schedule(@schedule)
          render :json => {:schedule_id => @schedule.id}
        rescue => e
          Rails.logger.error "Could not create schedule : #{e.message}"
          render :json => {:error => e.message}
        end

      else
        # TODO : We need error codes for this
        render :json => {:error => "Error : #{@schedule.errors.first[0]} #{@schedule.errors.first[1]}",
                         :content_type => 'text/plain',
                         :status => :unprocessable_entity}

      end # end (if @schedule.save)

    end # end (if @schedule)

  end

  # PUT /schedules/1
  # PUT /schedules/1.xml
  def update
    @schedule = Schedule.find(params[:id])

    respond_to do |format|

      # First create jobkey with existing name,group
      key = JobKey.new(@schedule.name, @schedule.group)

      if @schedule.update_attributes(params[:schedule])

        # reload schedule to refresh attributes
        @schedule.reload

        # Also update schedule in Quartz, if it already exists
        if RemoteJobScheduler.instance.scheduler.check_exists(key)
          RemoteJobScheduler.instance.update_schedule_trigger(@schedule)
        end

        format.html { redirect_to(@schedule, :notice => 'Schedule was successfully updated.') }
        format.xml { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml { render :xml => @schedule.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /schedules/1
  # DELETE /schedules/1.xml
  def destroy
    @schedule = Schedule.find(params[:id])

    @schedule.destroy

    key = JobKey.new(@schedule.name, @schedule.group)
    if RemoteJobScheduler.instance.scheduler.check_exists(key)
      RemoteJobScheduler.instance.remove_schedule(key)
    end

    respond_to do |format|
      format.html { redirect_to(schedules_url) }
      format.xml { head :ok }
    end
  end
end

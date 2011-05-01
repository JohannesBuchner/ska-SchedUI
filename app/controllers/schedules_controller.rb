class SchedulesController < ApplicationController
  # GET /schedules
  # GET /schedules.xml
  def index
    @schedules = Schedule.all

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /schedules/1
  # GET /schedules/1.xml
  def show
    @schedule = Schedule.find(params[:id])
    sc = ScheduleContent.find_by_sql("select * from schedule_contents WHERE Schedule_id = #{@schedule.id}")
    # @schedule_content = ScheduleContent.find_by_Schedule_id(@schedule.id)
    #if (@schedule_content.nil?)
    #  puts "--$$$$$$$$$$$--got nil!"
    #  @schedule_content = []
    #end
    #if (@schedule_content.class != Array)
    #  puts "--$$$$$$$$$$$--got only an entry!"
    #  @schedule_content = [@schedule_content]
    #end
    require 'java'
    @LST_SLOTS_MINUTES = Java::LocalRadioschedulers::Schedule::LST_SLOTS_MINUTES
    @LST_SLOTS_PER_HOUR = 60 / @LST_SLOTS_MINUTES
    @LST_SLOTS_PER_DAY = 24 * 60 / @LST_SLOTS_MINUTES
    
    @jobs = {}
    @schedule_content = {}
    sc.each do |sce|
      sce2 = sce
      if not @jobs.has_key?(sce.Job_id)
        @jobs[sce.Job_id] = Job.find_by_sql("select * from jobs WHERE id = #{sce.Job_id} LIMIT 1")
      end
      @schedule_content[sce.timeslot] = sce
    end

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @schedule }
    end
  end

  # GET /schedules/new
  # GET /schedules/new.xml
  def new
    @schedule = Schedule.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @schedule }
    end
  end

  # GET /schedules/1/edit
  def edit
    @schedule = Schedule.find(params[:id])
  end

  # POST /schedules
  # POST /schedules.xml
  def create
    @schedule = Schedule.new(params[:schedule])

    respond_to do |format|
      if @schedule.save
        format.html { redirect_to(@schedule, :notice => 'Schedule was successfully created.') }
        format.xml  { render :xml => @schedule, :status => :created, :location => @schedule }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @schedule.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /schedules/1
  # PUT /schedules/1.xml
  def update
    @schedule = Schedule.find(params[:id])

    respond_to do |format|
      if @schedule.update_attributes(params[:schedule])
        format.html { redirect_to(@schedule, :notice => 'Schedule was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @schedule.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /schedules/1
  # DELETE /schedules/1.xml
  def destroy
    @schedule = Schedule.find(params[:id])
    @schedule.destroy

    respond_to do |format|
      format.html { redirect_to(schedules_url) }
      format.xml  { head :ok }
    end
  end
end

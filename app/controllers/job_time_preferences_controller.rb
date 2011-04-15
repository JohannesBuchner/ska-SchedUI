class JobTimePreferencesController < ApplicationController
  def index
    @job_time_preferences = JobTimePreference.all
    @job_time_preference = JobTimePreference.new
    respond_to do |format|
      format.html  { render :file => 'job_time_preferences/dynamicindex.html.erb' }
    end
  end
  def dynamicindex
    @job_time_preferences = JobTimePreference.all
    @job_time_preference = JobTimePreference.new
    respond_to do |format|
      format.html # index.html.erb
    end
  end
  def show
    @job_time_preference = JobTimePreference.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
    end
  end
  def new
    @job_time_preference = JobTimePreference.new
    respond_to do |format|
      format.html # new.html.erb
    end
  end
  # GET /job_time_preference/1/edit
  def edit
    @job_time_preference = JobTimePreference.find(params[:id])
  end

  # POST /sources
  # POST /sources.xml
  def create
    @job_time_preference = JobTimePreference.new(params[:job_time_preference])

    respond_to do |format|
      if @job_time_preference.save
        format.html { redirect_to(@job_time_preference, :notice => 'JobTimePreference was successfully created.') }
        format.xml  { render :xml => @job_time_preference, :status => :created, :location => @job_time_preference }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @job_time_preference.errors, :status => :unprocessable_entity }
      end
    end
  end
  # DELETE /sources/1
  # DELETE /sources/1.xml
  def destroy
    @job_time_preference = JobTimePreference.find(params[:id])
    @job_time_preference.destroy

    respond_to do |format|
      format.html { redirect_to(job_time_preferences_url) }
      format.xml  { head :ok }
      format.js do
         render :update do |page|
           page.remove "image_#{@image.id}"  
         end     
       end
    end
  end
end

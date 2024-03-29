class BadDatesController < ApplicationController
  # GET /bad_dates
  # GET /bad_dates.xml
  def index
    @bad_dates = BadDate.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @bad_dates }
    end
  end

  # GET /bad_dates/1
  # GET /bad_dates/1.xml
  def show
    @bad_date = BadDate.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @bad_date }
    end
  end

  # GET /bad_dates/new
  # GET /bad_dates/new.xml
  def new
    @bad_date = BadDate.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @bad_date }
    end
  end

  # GET /bad_dates/1/edit
  def edit
    @bad_date = BadDate.find(params[:id])
  end

  # POST /bad_dates
  # POST /bad_dates.xml
  def create
    @bad_date = BadDate.new(params[:bad_date])

    respond_to do |format|
      if @bad_date.save
        format.html { redirect_to(@bad_date, :notice => 'Bad date was successfully created.') }
        format.xml  { render :xml => @bad_date, :status => :created, :location => @bad_date }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @bad_date.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /bad_dates/1
  # PUT /bad_dates/1.xml
  def update
    @bad_date = BadDate.find(params[:id])

    respond_to do |format|
      if @bad_date.update_attributes(params[:bad_date])
        format.html { redirect_to(@bad_date, :notice => 'Bad date was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @bad_date.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /bad_dates/1
  # DELETE /bad_dates/1.xml
  def destroy
    @bad_date = BadDate.find(params[:id])
    @bad_date.destroy

    respond_to do |format|
      format.html { redirect_to(bad_dates_url) }
      format.xml  { head :ok }
    end
  end
end

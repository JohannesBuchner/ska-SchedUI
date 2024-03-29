class ConstraintsController < ApplicationController
  # GET /constraints
  # GET /constraints.xml
  def index
    @constraints = Constraint.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @constraints }
    end
  end

  # GET /constraints/1
  # GET /constraints/1.xml
  def show
    @constraint = Constraint.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @constraint }
    end
  end

  # GET /constraints/new
  # GET /constraints/new.xml
  def new
    @constraint = Constraint.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @constraint }
    end
  end

  # GET /constraints/1/edit
  def edit
    @constraint = Constraint.find(params[:id])
  end

  # POST /constraints
  # POST /constraints.xml
  def create
    @constraint = Constraint.new(params[:constraint])

    respond_to do |format|
      if @constraint.save
        format.html { redirect_to(@constraint, :notice => 'Constraint was successfully created.') }
        format.xml  { render :xml => @constraint, :status => :created, :location => @constraint }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @constraint.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /constraints/1
  # PUT /constraints/1.xml
  def update
    @constraint = Constraint.find(params[:id])

    respond_to do |format|
      if @constraint.update_attributes(params[:constraint])
        format.html { redirect_to(@constraint, :notice => 'Constraint was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @constraint.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /constraints/1
  # DELETE /constraints/1.xml
  def destroy
    @constraint = Constraint.find(params[:id])
    @constraint.destroy

    respond_to do |format|
      format.html { redirect_to(constraints_url) }
      format.xml  { head :ok }
    end
  end
end

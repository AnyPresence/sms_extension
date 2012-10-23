class OutagesController < ApplicationController
  # GET /outages
  # GET /outages.json
  def index
    @outages = Outage.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @outages }
    end
  end

  # GET /outages/1
  # GET /outages/1.json
  def show
    @outage = Outage.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @outage }
    end
  end

  # GET /outages/new
  # GET /outages/new.json
  def new
    @outage = Outage.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @outage }
    end
  end

  # GET /outages/1/edit
  def edit
    @outage = Outage.find(params[:id])
  end

  # POST /outages
  # POST /outages.json
  def create
    @outage = Outage.new(params[:outage])

    respond_to do |format|
      if @outage.save
        format.html { redirect_to @outage, notice: 'Outage was successfully created.' }
        format.json { render json: @outage, status: :created, location: @outage }
      else
        format.html { render action: "new" }
        format.json { render json: @outage.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /outages/1
  # PUT /outages/1.json
  def update
    @outage = Outage.find(params[:id])

    respond_to do |format|
      if @outage.update_attributes(params[:outage])
        format.html { redirect_to @outage, notice: 'Outage was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @outage.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /outages/1
  # DELETE /outages/1.json
  def destroy
    @outage = Outage.find(params[:id])
    @outage.destroy

    respond_to do |format|
      format.html { redirect_to outages_url }
      format.json { head :no_content }
    end
  end
end

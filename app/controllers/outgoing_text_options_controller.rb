class OutgoingTextOptionsController < ApplicationController
  before_filter :find_available_objects, :except => [:index, :destroy]
    
  def index
    @outgoing_text_options = current_account.outgoing_text_options.all
  end
  
  def new
    @outgoing_text_option = current_account.outgoing_text_options.build
    menu_options = current_account.outgoing_text_options.all
    menu_options.each do |x|
      @available_objects.delete(x.name)
    end
  end
  
  def edit
    @outgoing_text_option = OutgoingTextOption.find(params[:id])
  end

  def update
    @outgoing_text_option =  OutgoingTextOption.find(params[:id])
    if @outgoing_text_option.update_attributes(params[:outgoing_text_option])
      flash[:notice] = "Outgoing text option has been updated."
      redirect_to [current_account, @menu_option]
    else
      flash[:alert] = "Outgoing text option has not been updated."
      render :action => "edit"
    end
  end
  
  def create
    @outgoing_text_option = current_account.outgoing_text_options.build(params[:outgoing_text_option].merge!(:account => current_account))
    if @outgoing_text_option.save
      flash[:notice] = "Outgoing text option has been created."
      redirect_to [current_account, @outgoing_text_option]
    else
      flash[:alert] = "Outgoing text option has not been created."
      render "new"
    end
  end
  
  def show
    @outgoing_text_option = OutgoingTextOption.find(params[:id])
  end
  
  def destroy
    @outgoing_text_option = current_account.outgoing_text_options.find(params[:id])
    @outgoing_text_option.destroy
    flash[:notice] = "Outgoing text option has been deleted."
    redirect_to settings_path
  end
end

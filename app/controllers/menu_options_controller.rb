class MenuOptionsController < ApplicationController
  before_filter :find_available_objects, :except => [:index, :destroy]
  
  def index
    @menu_options = current_account.menu_options.all
  end
  
  def new
    @menu_option = current_account.menu_options.build
  end
  
  def edit
    @menu_option = MenuOption.find(params[:id])
  end
  
  def create
    @menu_option = current_account.menu_options.build(params[:menu_option].merge!(:account => current_account))
    if @menu_option.save
      flash[:notice] = "Menu option has been created."
      redirect_to [current_account, @menu_option]
    else
      flash[:alert] = "Menu option has not been created."
      render "new"
    end
  end
  
  def update
    @menu_option =  MenuOption.find(params[:id])
    if @menu_option.update_attributes(params[:menu_option])
      flash[:notice] = "Menu option has been updated."
      redirect_to [current_account, @menu_option]
    else
      flash[:alert] = "Menu option has not been updated."
      render :action => "edit"
    end
  end
  
  def show
    @menu_option = MenuOption.find(params[:id])
  end
  
  def destroy
    @menu_option = current_account.menu_options.find(params[:id])
    @menu_option.destroy
    flash[:notice] = "Menu Option has been deleted."
    redirect_to settings_path
  end

private
  # Helper to build drop down menu with object names
  def find_available_objects
    begin
      @available_objects = current_account.get_object_definition_mappings
      if @available_objects.nil?
        flash[:alert] = "Unable to find any available objects. Please create objects for application #{application_name}."
        redirect_to settings_path
      end
    rescue ConsumeSms::GeneralTextMessageNotifierException
      flash[:alert] = "Unable to retrieve object names for building a menu."
      redirect_to settings_path
    end
  end
end

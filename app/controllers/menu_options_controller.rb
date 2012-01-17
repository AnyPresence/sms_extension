class MenuOptionsController < ApplicationController
  before_filter :find_available_objects, :except => [:index, :destroy]
  
  def index
    @menu_options = MenuOption.all
  end
  
  def new
    account = Account.find(params[:account_id])
    @menu_option = account.menu_options.build
  end
  
  def edit
    @menu_option = MenuOption.find(params[:id])
  end
  
  def create
    account = Account.find(params[:account_id])
    @menu_option = account.menu_options.build(params[:menu_option].merge!(:account => current_account))
    if @menu_option.save
      flash[:notice] = "Menu option has been created."
      redirect_to [account, @menu_option]
    else
      flash[:alert] = "Menu option has not been created."
      render "new"
    end
  end
  
  def update
    account = Account.find(params[:account_id])
    @menu_option =  MenuOption.find(params[:id])
    if @menu_option.update_attributes(params[:menu_option])
      flash[:notice] = "Menu option has been updated."
      redirect_to [account, @menu_option]
    else
      flash[:alert] = "Menu option has not been updated."
      render :action => "edit"
    end
  end
  
  def show
    @menu_option = MenuOption.find(params[:id])
  end
  
  def destroy
    account = Account.find(params[:account_id])
    @menu_option = account.menu_options.find(params[:id])
    @menu_option.destroy
    flash[:notice] = "Menu Option has been deleted."
    redirect_to settings_path
  end

private
  # Helper to build drop down menu with object names
  def find_available_objects
    account = Account.find(params[:account_id])
    application_name = Account::get_application_name(account.application_id)
    @available_objects = account.get_object_definition_mappings(application_name)
  end
end

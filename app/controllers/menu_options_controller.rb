class MenuOptionsController < ApplicationController
  before_filter :find_available_objects, :except => [:index, :destroy]
  
  def index
    @menu_options = current_account.menu_options.all
  end
  
  def new
    @menu_option = current_account.menu_options.build
    
    menu_options = current_account.menu_options.all
    menu_options.each do |x|
      @available_objects.delete(x.name)
    end
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

end

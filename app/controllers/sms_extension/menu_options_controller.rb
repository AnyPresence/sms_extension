module SmsExtension
  class MenuOptionsController < ApplicationController
    before_filter :find_available_objects, :except => [:index, :destroy]
  
    def index
      @menu_options = current_account.menu_options.where(:type => params[:type])
    end
  
    def new
      case params[:type]
      when "OutgoingTextOption"
        @menu_option = current_account.outgoing_text_options.build
      when "BulkTextPhoneNumber"
        @menu_option = BulkTextPhoneNumber.new
      else
        @menu_option = current_account.menu_options.build
      end

      menu_options = current_account.menu_options.where(:type => params[:type]).all
      menu_options.each do |x|
        @available_objects.delete(x.name)
      end
    end
  
    def edit
      @menu_option = MenuOption.find(params[:id])
    end
  
    def create
      case params[:type]
      when "OutgoingTextOption"
        @menu_option = current_account.menu_options.build(params[:outgoing_text_option].merge!(:account => current_account))
      when "BulkTextPhoneNumber"
        @menu_option = BulkTextPhoneNumber.new(params[:bulk_text_phone_number].merge!(:account => current_account))
      else
        @menu_option = current_account.menu_options.build(params[:menu_option].merge!(:account => current_account))
      end

      @menu_option.type = params[:type]

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
      param_name = ""
      case params[:type]
      when "OutgoingTextOption"
        param_name = :outgoing_text_option
      when "BulkTextPhoneNumber"
        param_name = :bulk_text_phone_number
      else
        param_name = :menu_option
      end
      if @menu_option.update_attributes(params[param_name])
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
end
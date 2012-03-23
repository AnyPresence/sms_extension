module AnypresenceExtension
  class SettingsController < ApplicationController
    # We can do SSO from the hash AnyPresence sends
    before_filter :authenticate_from_anypresence, :only => [:deprovision, :settings, :publish]

    # Normal Devise authentication logic
    before_filter :authenticate_account!, :except => [:unauthorized, :provision, :index]
    
    before_filter :find_api_version, :only => [:provision, :publish]

    # Just something for root_path for Devise.
    def unauthorized
      render :text => "Unauthorized.", :status => :unauthorized
    end
    
    # This creates an account on our side tied to the application and renders back the expected result to create a new add on instance.
    def provision
      Rails.logger.debug "Provisioning account: " + params.inspect

      if valid_request?
        account = Account.where(:application_id => params[:application_id]).first
        if account.nil?
          account = Account.new
          account.application_id = params[:application_id]
        end
        account.extension_id = params[:add_on_id]
        account.api_token = params[:api_token]
        account.api_version = @api_version
        account.api_host = "#{ENV['CHAMELEON_HOST']}".strip.gsub(/\/+$/, '')

        account.save!
        
        extension_name = ENV["EXTENSION_NAME"].nil? ? "Unamed Extension" : ENV["EXTENSION_NAME"]
        
        render :json => {
          :success => true,
          :build_objects => [
            {
              :type => 'WebService',
              :name => extension_name,
              :url => perform_url,
              :method => 'POST',
              :web_service_fields_attributes => [
                { :name => "auth_token", :value => account.authentication_token }
              ]
            }
          ]
        }
      else      
        Rails.logger.error "Unable to provision...: " + params.inspect
        render :json => { :success => false }
      end
    end
    
    alias :provision! :provision

    # This deprovisions the current account. We can't get here unless we're signed in, so we know it's a valid request.
    def deprovision
      current_account.destroy
      render :json => { :success => true }
    end
    
    alias :deprovision! :deprovision

    # This renders our settings page and handles updates of the account.
    def settings
      if request.put?
        if current_account.update_attributes params[:account]
          flash[:notice] = "Account updated."
          redirect_to settings_path
        else
          flash[:alert] = "Account could not be updated."

          render :action => "settings", :controller => "texter"
        end
      end
    end
    
    alias :settings! :settings

    # This is the endpoint for when new applications are published
    def publish
      new_api_version = @api_version

      if new_api_version.nil?
         render :json => { :success => false } 
      elsif current_account.api_version.nil? || new_api_version.to_i > current_account.api_version.to_i
        Rails.logger.info "new api version found: " + @api_version
        current_account.api_version = new_api_version
        current_account.save!

        render :json => { :success => true, :message => "The extensions will now use the latest version."}
      else
        render :json => { :success => true }
      end
    end
    
    alias :publish! :publish
      
protected
    # If the request is valid, we log in as the account tied to the application that was passed.
    def authenticate_from_anypresence
      if valid_request?
        account = Account.find_by_application_id params[:application_id]
        if account.nil?
          raise "Unable to find the account."
        end
        sign_in account
      elsif current_account
        true
      else
        unauthorized 
      end
    end

    # A request is valid if it is both recent and was properly signed with our shared secret.
    def valid_request?
      signed_secret = AnypresenceExtension::Authenticatable::sign_secret(ENV['SHARED_SECRET'], params[:application_id], params[:timestamp])
      recent_request? && params[:anypresence_auth] == signed_secret[:anypresence_auth]
    end

    # We define the request as recent if it originated from the AnyPresence server more than 30 seconds ago. This should be enough time
    # for both network latency and clock synchronization issues.
    def recent_request?
      begin
        Time.at(params[:timestamp].to_i) > 30.seconds.ago
      rescue
        false
      end
    end

    # Finds the API version in the header.
    def find_api_version
      if Rails.env.test?
        @api_version = request.env["X_AP_API_VERSION"]
      else
        @api_version = request.env["HTTP_X_AP_API_VERSION"]
      end
    end

    # Finds the object definition name.
    def find_object_definition_name
      if Rails.env.test?
        @object_definition_name = request.env["X_AP_OBJECT_DEFINITION_NAME"]
      else
        @object_definition_name = request.env["HTTP_X_AP_OBJECT_DEFINITION_NAME"]
      end
    end
  end
end

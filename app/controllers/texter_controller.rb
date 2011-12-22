class TexterController < ApplicationController
  # Our config action authenticates against the AnyPresence parameters sent
  before_filter :authenticate_from_anypresence, :only => :settings
  
  # Normal Devise authentication logic
  before_filter :authenticate_account!, :except => :provision

  # This creates an account on our side tied to the application and renders back the expected result to create a new add on instance.
  def provision
    if valid_request?
      account = Account.new
      account.application_id = params[:application_id]
      account.save!
      
      render :json => {
        :success => true,
        :build_objects => [
          {
            :type => 'WebService',
            :name => 'Text Notification Service',
            :url => text_url,
            :method => 'POST',
            :web_service_fields_attributes => [
              { :name => "auth_token", :value => account.authentication_token }
            ]
          }
        ]
      }
    else      
      render :json => { :success => false }
    end
  end
  
  # This renders our settings page and handles updates of the account.
  def settings
    if request.put?
      if current_account.update_attributes params[:account]
        flash[:notice] = "Account updated."
      else
        flash[:alert] = "Account could not be updated."
      end
      redirect_to settings_path
    end
  end
  
  # This is the endpoint for the web service our add on creates.
  def text
    twilio_account = Twilio::REST::Client.new(ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN']).account
    if current_account.phone_number.blank? || current_account.field_name.blank?
      render :text => "Not yet set up!"
    else
      begin
        twilio_account.sms.messages.create(:from => "4155992671", :to => current_account.phone_number, :body => "#{params[current_account.field_name] || 'unknown'} was created")
        render :text => "sent!"
      rescue
        render :text => "Error! #{$!.message}"
      end
    end
  end

protected
  # If the request is valid, we log in as the account tied to the application that was passed.
  def authenticate_from_anypresence
    if valid_request?
      account = Account.find_by_application_id params[:application_id]
      sign_in account
    end
  end
  
  # A request is valid if it is both recent and was properly signed with our shared secret.
  def valid_request?
    recent_request? && params[:anypresence_auth] == Digest::SHA1.hexdigest("#{ENV['SHARED_SECRET']}-#{params[:application_id]}-#{params[:timestamp]}")
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
end

class TexterController < ApplicationController
    
  # We can do SSO from the hash AnyPresence sends
  before_filter :authenticate_from_anypresence, :only => [:settings, :deprovision]
  
  # Normal Devise authentication logic
  before_filter :authenticate_account!, :except => [:unauthorized, :provision]

  # Just something for root_path for Devise.
  def unauthorized
    render :text => "Unauthorized.", :status => :unauthorized
  end

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
  
  # This deprovisions the current account. We can't get here unless we're signed in, so we know it's a valid request.
  def deprovision
    current_account.destroy
    render :json => { :success => true }
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
        twilio_account.sms.messages.create(:from => ENV['TWILIO_FROM_SMS_NUMBER'], :to => current_account.phone_number, :body => "#{params[current_account.field_name] || 'unknown'} was created")
        render :json => { :success => true }
      rescue
        render :json => { :success => false, :error => $!.message }
      end
    end
  end

  # Twilio sends a post to this endpoint
  def consume
    message = Message.new(:smsMessageSid => params[:smsMessageSid], :accountSid => params[:accountSid], :body => params[:body], :from => params[:from], :to =>params[:to])

    if message.save
      # Parse the message and decide what message to send back (if any)
      parse_message(message)
      
      render :json => { :success => true }
    else
      render :json => { :success => false, :error => message.errors }
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
    Rails.logger.info "expecting: " + Digest::SHA1.hexdigest("#{ENV['SHARED_SECRET']}-#{params[:application_id]}-#{params[:timestamp]}")
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

  # Parse the message and decide what to send back
  # TODO -- functionality to be decided shortly
  def parse_message(message)
  end
  
end

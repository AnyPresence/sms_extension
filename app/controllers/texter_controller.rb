class TexterController < ApplicationController

  # We can do SSO from the hash AnyPresence sends
  before_filter :authenticate_from_anypresence, :only => [:settings, :deprovision, :publish]
  
  # Normal Devise authentication logic
  before_filter :authenticate_account!, :except => [:unauthorized, :provision, :consume, :generate_consume_phone_number]

  before_filter :find_api_version, :only => [:provision, :text, :publish]
  
  # Just something for root_path for Devise.
  def unauthorized
    render :text => "Unauthorized.", :status => :unauthorized
  end

  # This creates an account on our side tied to the application and renders back the expected result to create a new add on instance.
  def provision
    if valid_request?
      account = Account.new
      account.application_id = params[:application_id]
      account.api_version = @api_version
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
      consume_phone_number = params[:account][:consume_phone_number]

      # Check if we should provision this phone number, or if we own it already.
      if current_account.consume_phone_number.nil? && !consume_phone_number.nil?
        used_numbers = Account::get_used_phone_numbers
        used_numbers << consume_phone_number
        twilio_account = Twilio::REST::Client.new(ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN']).account 
        
        # Check to see if there are numbers that we own that are not being used by any account
        twilio_owned_numbers = twilio_account.incoming_phone_numbers.list
        first_available_owned_number = Account::phone_number_used(twilio_owned_numbers, used_numbers)

        # Check if we have a phone number available. 
        if first_available_owned_number.nil?
          begin
            # Let's buy this phone number.
            twilio_account.incoming_phone_numbers.create({:phone_number => consume_phone_number, :sms_url => ENV['SMS_CONSUME_URL']})
          rescue
            params[:account][:consume_phone_number] = nil
          end
        else
          # Use the phone number we already own but update the sms url.
          sid = ""
          twilio_owned_numbers.each do |x|
            sid = x.sid if x.phone_number.match(Message::strip_phone_number_prefix(consume_phone_number))
          end
          
          begin
            twilio_account.incoming_phone_numbers.get(sid).update({:sms_url => ENV['SMS_CONSUME_URL']})
          rescue
            flash[:alert] = "Unable to update the url to consume SMS on Twilio."
          end
        end
      end

      if current_account.update_attributes params[:account]
        flash[:notice] = "Account updated."
      else
        flash[:alert] = "Account could not be updated."
      end
      
      redirect_to settings_path
    end

  end
  
  # This is the endpoint for when new applications are published
  def publish
    new_api_version = @api_version
    
    if new_api_version.nil?
       render :json => { :success => false } 
    elsif new_api_version > current_account.api_version
      current_account.api_version = new_api_version
      current_account.save!
      
      render :json => { :success => true, :message => "The extensions will now use the latest version."}
    else
      render :json => { :success => true }
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
    message = Message.new(:sms_message_sid => params[:SmsMessageSid], :account_sid => params[:AccountSid], :body => params[:Body], :from => params[:From], :to => params[:To])
    twilio_account = Twilio::REST::Client.new(ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN']).account
    Rails.logger.info "Received message: " + message.inspect
    if message.save
      # Parse the message and decide what message to send back (if any)
      # TODO: Hooks must be created in the exposed API so that we know what the latest published app is.
      incoming_phone_number = Message::strip_phone_number_prefix(params[:From])
      
      consume_phone_number = Message::strip_phone_number_prefix(params[:To])
      accounts = Account.where("consume_phone_number like ?", "%#{consume_phone_number}")
      
      begin
        outbound_message = ""
        
        if !accounts.blank?
          consumer = ConsumeSms::Consumer.new(accounts.first.application_id, accounts.first.field_name)
        
          begin
            outbound_message = consumer.consume_sms(message, accounts.first.text_message_options)
          rescue
            outbound_message = "Unable to obtain data at this time. Please try again later."
            #TODO: raise another exception here instead of muffing out
          end
        else
          outbound_message = "The extension is not configured for your account."
        end

        Rails.logger.info "Sending message to " + message.from + " : " + outbound_message
    
        twilio_account.sms.messages.create(:from => ENV['TWILIO_FROM_SMS_NUMBER'], :to => message.from, :body => outbound_message)
        render :json => { :success => true }
      rescue
        render :json => { :success => false, :error => $!.message }
      end
    else
      render :json => { :success => false, :error => message.errors }
    end
  end
  
  # Generates a phone number to consume SMS
  def generate_consume_phone_number
    if current_account.consume_phone_number.nil?
      used_numbers = Account::get_used_phone_numbers
     
      twilio_client = Twilio::REST::Client.new(ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN'])
      twilio_account = twilio_client.account
      
      # Check to see if there are numbers that we own that are not being used by any account
      twilio_owned_numbers = twilio_account.incoming_phone_numbers.list
      first_available_owned_number = Account::phone_number_used(twilio_owned_numbers, used_numbers)
      
      # Try to obtain a new number from Twilio
      if first_available_owned_number.nil?
        area_code = params[:area_code]
        # Get available numbers in area code
        local_numbers = twilio_account.available_phone_numbers.get('US').local
        numbers = local_numbers.list(:area_code => area_code)
        first_available_owned_number = numbers.first.phone_number if !numbers.nil?
      end

      current_account.consume_phone_number = first_available_owned_number
    end
    
    respond_to do |format|  
      format.js
    end

  end
  
protected
  # If the request is valid, we log in as the account tied to the application that was passed.
  def authenticate_from_anypresence
    if valid_request?
      account = Account.find_by_application_id params[:application_id]
      if account.nil?
        return false
      end
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
  
  def find_api_version
    if Rails.env.test?
      @api_version = request.env["X_AP_API_VERSION"]
    else
      @api_version = request.env["HTTP_X_AP_API_VERSION"]
    end
  end

end

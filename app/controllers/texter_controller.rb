class TexterController < ApplicationController

  # We can do SSO from the hash AnyPresence sends
  before_filter :authenticate_from_anypresence, :only => [:deprovision, :settings, :publish]
  
  # Normal Devise authentication logic
  before_filter :authenticate_account!, :except => [:unauthorized, :provision, :consume, :generate_consume_phone_number, :text_phone_number]

  before_filter :find_api_version, :only => [:provision, :text, :publish]
  before_filter :find_object_definition_name, :only => [:text]
  before_filter :build_consumer, :only => [:settings, :text, :generate_consume_phone_number]

  # Just something for root_path for Devise.
  def unauthorized
    render :text => "Unauthorized.", :status => :unauthorized
  end

  # This creates an account on our side tied to the application and renders back the expected result to create a new add on instance.
  def provision
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
      if params[:account][:consume_phone_number] == "N/A"
        consume_phone_number = params[:account][:consume_phone_number] = nil
      else
        consume_phone_number = params[:account][:consume_phone_number]
      end

      # Check if we should provision this phone number, or if we own it already.
      if current_account.consume_phone_number.nil? && !consume_phone_number.nil?
        # Check if we have a phone number available. 
        if @consumer.provision_new_phone_number?(consume_phone_number)
          begin
            # Let's buy this phone number.
            @consumer.provision_new_phone_number(consume_phone_number, ENV['SMS_CONSUME_URL'])
          rescue
            params[:account][:consume_phone_number] = nil
          end
        else
          # Use the phone number we already own but update the sms url.
          begin
            @consumer.update_sms_url(consume_phone_number)
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
    elsif current_account.api_version.nil? || new_api_version.to_i > current_account.api_version.to_i
      Rails.logger.info "new api version found: " + @api_version
      current_account.api_version = new_api_version
      current_account.save!
      
      render :json => { :success => true, :message => "The extensions will now use the latest version."}
    else
      render :json => { :success => true }
    end
  end
  
  # This is the endpoint for the web service our add on creates.
  def text
    if current_account.phone_number.blank? && current_account.outgoing_text_options.blank?
      Rails.logger.error "Not able to send text. The account is either missing a phone number to text to, or there are no outgoing text options."
      render :text => "Not yet set up!"
    else
      begin
        outgoing_text_option = current_account.outgoing_text_options.where(:name => @object_definition_name.downcase).first
        phone_number = current_account.phone_number
        unless outgoing_text_option.blank?
          new_phone_number = MenuOption::parse_format_string(outgoing_text_option.phone_number_field,  @object_definition_name, params)
          raise ConsumeSms::GeneralTextMessageNotifierException, "Unable to obtain phone number to send sms to." if (phone_number.blank? && new_phone_number.blank?)
          phone_number = new_phone_number unless new_phone_number.blank? 
        end
        # The attributes of the object are in params, so we'll just pass that over
        from_phone_number = ENV['TWILIO_FROM_SMS_NUMBER']
        from_phone_number = current_account.consume_phone_number unless current_account.consume_phone_number.blank?
        @consumer.text({:from => from_phone_number, :to => phone_number, :body => "#{params[current_account.field_name] || 'unknown'} was created"}, params, @object_definition_name.downcase)
        render :json => { :success => true }
      rescue
        Rails.logger.error "Unable to send out text to : " + $!.message
        Rails.logger.error $!.backtrace
        render :json => { :success => false, :error => $!.message }
      end
    end
  end

  # Twilio sends a post to this endpoint
  def consume
    message = Message.new(:sms_message_sid => params[:SmsMessageSid], :account_sid => params[:AccountSid], :body => params[:Body], :from => params[:From], :to => params[:To])
    Rails.logger.info "Received message: " + message.inspect
    if message.save
      incoming_phone_number = Message::strip_phone_number_prefix(params[:From])
      consume_phone_number = Message::strip_phone_number_prefix(params[:To])
      accounts = Account.where("consume_phone_number like ?", "%#{consume_phone_number}")
      
      begin
        outbound_message = ""
        if !accounts.blank?
          begin
            consumer = ConsumeSms::Consumer.new(accounts.first)
            outbound_message = consumer.consume_sms(message, accounts.first.text_message_options)
          rescue
            Rails.logger.error "Not able to consume the text: " 
            outbound_message = "Unable to obtain data at this time. Please try again later."
          end
        else
          outbound_message = "The extension is not configured for your account."
        end

        Rails.logger.info "Sending message to " + message.from + " : " + outbound_message.inspect
        outbound_message = [outbound_message] unless outbound_message.kind_of?(Array)
        outbound_message.each do |o|
          ConsumeSms::Consumer.send_sms({:from => consume_phone_number, :to => message.from, :body => o.to_s})
        end
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
      first_available_owned_number = @consumer.find_available_purchased_phone_number(Account::get_used_phone_numbers)
      # Try to obtain a new number from Twilio
      current_account.consume_phone_number =  first_available_owned_number.nil? ? @consumer.get_phone_number_to_purchase(params[:area_code]) : first_available_owned_number
    end
    
    respond_to do |format|  
      format.js
    end
  end
  
  def text_phone_number
    @available_objects = current_account.object_definition_mappings
    @bulk_text_phone_number = BulkTextPhoneNumber.where(:account_id => current_account.id).first
    
    if request.post?
      @bulk_text_phone_number = BulkTextPhoneNumber.new(params[:bulk_text_phone_number].merge!(:type => 'BulkTextPhoneNumber'))
      @bulk_text_phone_number.account = current_account
      
      if @bulk_text_phone_number.save
        flash[:notice] = "Account updated."
      else
        flash[:alert] = "Account could not be updated."
      end
      
      redirect_to settings_path
    elsif request.put?
      if @bulk_text_phone_number.update_attributes(params[:bulk_text_phone_number].merge!({:account => current_account, :type => 'BulkTextPhoneNumber'}))
        flash[:notice] = "Account updated."
      else
        flash[:alert] = "Account could not be updated."
      end
      
      redirect_to settings_path
    elsif request.delete?
      @bulk_text_phone_number.destroy
      flash[:notice] = "Deleted bulk text option."
      
      redirect_to settings_path
    else
      @bulk_text_phone_number = BulkTextPhoneNumber.new if @bulk_text_phone_number.blank?
    end
  
  end

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
    signed_secret = ConsumeSms::sign_secret(ENV['SHARED_SECRET'], params[:application_id], params[:timestamp])
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

  # Builds the +Consumer+ which accesses Twilio.
  def build_consumer
    @consumer = ConsumeSms::Consumer.new(current_account)
  end

end

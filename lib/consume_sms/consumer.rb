module ConsumeSms
  class << self
    def sign_secret(shared_secret_key, application_id, timestamp)
      anypresence_auth = Digest::SHA1.hexdigest("#{shared_secret_key}-#{application_id}-#{timestamp}")
      {:anypresence_auth => anypresence_auth, :application_id => application_id, :timestamp => timestamp.to_s}
    end
  end
  
  class Consumer
     
    def initialize(account)
      @account = account
    end
    
    def twilio_account
      @twilio_account ||= Twilio::REST::Client.new(ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN']).account 
    end
    
    # Provisions new phone number with Twilio.
    def provision_new_phone_number(phone_number, sms_consume_url)
      begin
        twilio_account.incoming_phone_numbers.create({:phone_number => phone_number, :sms_url => sms_consume_url})
      rescue => e
        Rails.logger.error "Unable to provision number: " + phone_number + " , sms_url: " + sms_consume_url
        raise e
      end
    end
    
    def find_available_purchased_phone_number(used_numbers)    
      # Check to see if there are numbers that we own that are not being used by any account
      twilio_owned_numbers = twilio_account.incoming_phone_numbers.list
      first_available_owned_number = Account::phone_number_used(twilio_owned_numbers, used_numbers)
    end
    
    # Checks to see if we should provision a new phone number or use what is available.
    def provision_new_phone_number?(phone_number)
      used_numbers = Account::get_used_phone_numbers
      used_numbers << phone_number
      if find_available_purchased_phone_number(used_numbers).nil?
        true
      else
        false
      end
    end
    
    # Gets phone number to purchase by area code
    def get_phone_number_to_purchase(area_code)
      local_numbers = twilio_account.available_phone_numbers.get('US').local
      numbers = local_numbers.list(:area_code => area_code)
      numbers.first.phone_number if !numbers.nil?
    end
    
    # Updates SMS_URL for phone number
    def update_sms_url(phone_number)
      twilio_owned_numbers = twilio_account.incoming_phone_numbers.list
      sid = ""
      twilio_owned_numbers.each do |x|
        sid = x.sid if x.phone_number.match(Message::strip_phone_number_prefix(phone_number))
      end
      
      twilio_account.incoming_phone_numbers.get(sid).update({:sms_url => ENV['SMS_CONSUME_URL']})
    end
    
    # Consumes the message and returns a message to send back to the client.
    def consume_sms(message, text_message_options)
      object_name = text_message_options[message.body.strip] ? text_message_options[message.body.strip][0] : nil
      format = !object_name.nil? ? text_message_options[message.body.strip][1] : ""
      if message.body.strip == "#0" || object_name.nil?
        keys = text_message_options.keys
        info_message = ""
        keys.each do |x|
          info_message << "#{x} for #{text_message_options[x][0]}\n"
        end
      
        return info_message
      end

      @account.object_instances_as_sms(object_name, format)
    end
    
    # Builds text message to send out.
    #  +options+ is a hash that includes: +:from+, caller's phone number; +:to+, twilio phone number the caller sent the text to; and +body+. body of the text
    #  +params+ are attributes for the object
    #  +object_name+ is the object definition name
    def text(options={}, params, object_name)
      outgoing_text_option = @account.outgoing_text_options.where(:name => object_name).first
      # Find the format string from fields that were passed.
      body = outgoing_text_option.build_text(object_name, params)
      
      # Find the phone number to text to
      bulk_text_phone_number = @account.bulk_text_phone_number
      unless bulk_text_phone_number.blank?
        format = @account.bulk_text_phone_number.format
        object_name_with_phone_number = @account.bulk_text_phone_number.name
        options["body"] = body
        Resque.enqueue(LifecycleTriggeredSms, options, @account.id, object_name_with_phone_number, format)
      else
        # TODO: move this to resque as well.
        twilio_account.sms.messages.create(:from => options[:from], :to => options[:to], :body => body)
      end
    end
    
    # Sends text.
    def self.send_sms(options={})
      twilio_account = Twilio::REST::Client.new(ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN']).account

      twilio_account.sms.messages.create(:from => options[:from], :to => options[:to], :body => options[:body])
    end
  end
  
  # General Exception
  class GeneralTextMessageNotifierException < Exception; end
   
end
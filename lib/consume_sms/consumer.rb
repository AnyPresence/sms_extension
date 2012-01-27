module ConsumeSms
  class << self
    def connect_to_api(url, *parameters)
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
    
      response = nil
      if uri.scheme == "https"
        http.use_ssl = true
        # Might want to use another solution here for SSL.
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
      request = Net::HTTP::Get.new(uri.request_uri)
      request.set_form_data parameters if !parameters.nil?
      response = http.request request
    end
    
    def sign_secret(shared_secret_key, application_id, timestamp)
      anypresence_auth = Digest::SHA1.hexdigest("#{shared_secret_key}-#{application_id}-#{timestamp}")
      
      {:anypresence_auth => anypresence_auth, :application_id => application_id, :timestamp => timestamp}
    end
    
  end
  
  class Consumer
    
    NUM_ENTRIES = 1
    TWILIO_SMS_CHAR_PAGE_SIZE = 150
     
    def initialize(account)
      @account = account
      @twilio_account = Twilio::REST::Client.new(ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN']).account 
    end
    
    # Provisions new phone number with Twilio.
    def provision_new_phone_number(phone_number, sms_consume_url)
      begin
        @twilio_account.incoming_phone_numbers.create({:phone_number => phone_number, :sms_url => sms_consume_url})
      rescue => e
        Rails.logger.error "Unable to provision number: " + phone_number + " , sms_url: " + sms_consume_url
        raise e
      end
    end
    
    def find_available_purchased_phone_number(used_numbers)    
      # Check to see if there are numbers that we own that are not being used by any account
      twilio_owned_numbers = @twilio_account.incoming_phone_numbers.list
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
      local_numbers = @twilio_account.available_phone_numbers.get('US').local
      numbers = local_numbers.list(:area_code => area_code)
      numbers.first.phone_number if !numbers.nil?
    end
    
    # Sends text.
    def text(options={})
      @twilio_account.sms.messages.create(:from => options[:from], :to => options[:to], :body => options[:body])
    end
    
    # Updates SMS_URL for phone number
    def update_sms_url(phone_number)
      twilio_owned_numbers = @twilio_account.incoming_phone_numbers.list
      sid = ""
      twilio_owned_numbers.each do |x|
        sid = x.sid if x.phone_number.match(Message::strip_phone_number_prefix(phone_number))
      end
      
      @twilio_account.incoming_phone_numbers.get(sid).update({:sms_url => ENV['SMS_CONSUME_URL']})
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
      else
        url = "#{ENV['CHAMELEON_HOST']}/applications/#{@account.application_id}/api/versions/#{@account.api_version}/objects/#{object_name}/instances.json"
      end
      
      response = ConsumeSms::connect_to_api(url)
      
      parsed_json = []
      case response
      when Net::HTTPSuccess
        begin
          parsed_json = ActiveSupport::JSON.decode(response.body)
        rescue MultiJson::DecodeError
          raise ConsumeSms::GeneralTextMessageNotifierException, "Unable to decode the JSON message for url: #{url}"
        end
      when Net::HTTPRedirection
        raise ConsumeSms::GeneralTextMessageNotifierException, "Unexpected redirection occurred for url: #{url}"
      else
        raise ConsumeSms::GeneralTextMessageNotifierException, "Unable to get a response for url: #{url}"
      end        
      
      msg_for_client = []
      count = 0
      parsed_json.each do |x|
          break if count == NUM_ENTRIES
          count += 1
          msg_for_client << MenuOption::parse_format_string(format, x)
      end
  
      return msg_for_client.join("\n")
    end
    
  end
  
  # General Exception
  class GeneralTextMessageNotifierException < Exception; end
   
end
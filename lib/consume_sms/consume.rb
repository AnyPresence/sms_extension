module ConsumeSms
  def self.connect_to_api(url)
    url = url + "?auth_token=#{ENV['AUTH_TOKEN']}"
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    
    response = nil
    if uri.scheme == "https"
      http.use_ssl = true
      # Might want to use another solution here for SSL.
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end
    request = Net::HTTP::Get.new(uri.request_uri)

    response = http.request(request)
  end
  
  class Consumer
    
    NUM_ENTRIES = 1
    TWILIO_SMS_CHAR_PAGE_SIZE = 150
     
    def initialize(application_id, field_name)
      @application_id = application_id
      @field_name = field_name
    end
    
    # Consumes the message and returns a message to send back to the client.
    def consume_sms(message, text_message_options)
      object_name = text_message_options[message.body.strip]
      if message.body.strip == "#0" || object_name.nil?
        keys = text_message_options.keys
        info_message = ""
        keys.each do |x|
          info_message << "text #{x} for #{text_message_options[x]}\n"
        end
      
        return info_message
      else
        url = "#{ENV['CHAMELEON_HOST']}/applications/#{@application_id}/api/versions/v1/objects/#{object_name}/instances.json"
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
        raise ConsumeSms::GeneralTextMessageNotifierException, "Unable to get a response from for url: #{url}"
      end        
      
      # Note: this is hardcoded for outage-reports. Chameleon's exposed API must be expanded first 
      # to allow more dynamic functionality.
      msg_for_client = []
      count = 0
      parsed_json.each do |x|
          break if count == NUM_ENTRIES
          count += 1
          msg_for_client << x["title"] + " : " + x["description"]
      end
      
      return msg_for_client.join("\n")
    end
  end
  
  # General Exception
  class GeneralTextMessageNotifierException < Exception; end
   
end
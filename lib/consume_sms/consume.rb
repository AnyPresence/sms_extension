module ConsumeSms
  class Consumer
    
    NUM_ENTRIES = 1
    TWILIO_SMS_CHAR_PAGE_SIZE = 150
     
    def initialize(application_id, field_name)
      @application_id = application_id
      @field_name = field_name
    end
    
    # Accesses the API for the latest application version
    def get_latest_app_version
      # TODO: requires hooks in the API for this functionality
      "v8"
    end
    
    # Consumes the message and returns a message to send back to the client.
    def consume_sms(message, text_message_options)
      latest_appplication_version = get_latest_app_version
      object_name = text_message_options[message.body.strip]
      if message.body.strip=="#0" || object_name.nil?
        keys = text_message_options.keys
        info_message = ""
        keys.each do |x|
          info_message << "text #{x} for #{text_message_options[x]}\n"
        end
        Rails.logger.info "return message: " + info_message
        return info_message
      else
        url = "#{ENV['CHAMELEON_HOST']}/applications/#{@application_id}/api/versions/#{latest_appplication_version}/objects/#{object_name}/instances.json"
      end
      # Currently, I think that there's no API exposed to see what objects are available. We'll hardcode the below for demoing for now.
      uri = URI(url)
      response = Net::HTTP.get_response uri
      
      parsed_json = []
      case response
      when Net::HTTPSuccess
        begin
          parsed_json = ActiveSupport::JSON.decode(response.body)
        rescue MultiJson::DecodeError
          raise "hell"
        end
      when Net::HTTPRedirection
        # TODO: Handle redirection
        raise 'hell'
      else
        # TODO: Handle error
        raise 'hell'
      end        

      # Parse through the object instances and pull out the latest data.
      obj_def = []
      objs = {}
      parsed_json.each do |x| 
        time = Time.parse(x["object_definition"]["created_at"]).to_i
        objs[time] ||= []
        objs[time] << x["attributes"]
      end

      msg_for_client = [];
      keys = objs.keys.sort.reverse
      
      # Note: this is hardcoded for outage-reports. Chameleon's exposed API must be expanded first 
      # to allow more dynamic functionality.
      count = 0;
      keys.each do |k|
        val = objs[k]
        val.each do |v|
          break if count == NUM_ENTRIES
          count = count +1;
          time = Time.at(k).strftime('%F %T')
          msg_for_client << "#{time} : #{v['title']} : #{v[@field_name]}"
        end
      end
      
      return msg_for_client.join("\n")
    end
    
  end
   
end
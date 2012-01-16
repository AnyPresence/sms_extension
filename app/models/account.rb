class Account < ActiveRecord::Base
  devise :token_authenticatable, :rememberable, :trackable
  before_save :ensure_authentication_token
  
  validates_presence_of :application_id

  attr_accessible :remember_me, :phone_number, :field_name, :consume_phone_number, :application_id, :permitted_phone_numbers
  
  # Builds the message options that is available for the account.
  # For example, #0 for menu screen
  #              #1 for information about objectA (e.g. outage)
  #              #2 for information about objectA
  # TODO: This will need to be pulled from the database once we're able to obtain availabe objects from the API
  def text_message_options
    options = {}
    options["#0"] = "menu"
    options["#1"] = "outage"
    options["#2"] = "other_object"
    
    options
  end
  
  # Gets object definition names for an application
  def get_object_definition_mappings(application_name)
    url = "#{ENV['CHAMELEON_HOST']}/applications/#{application_name}/objects.json"
    
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
    
    object_names = []
    parsed_json.each do |x|
      object_names << x["mapping"]
    end
    
    object_names
  end
  
  # Gets the first available phone number if any
  def self.phone_number_used(twilio_owned_numbers, used_numbers)
    available_phone_number = nil
    twilio_owned_numbers.each do |x|
      if !used_numbers.include?(x.phone_number)
        available_phone_number = x.phone_number
        break
      end
    end
    return available_phone_number
  end
end

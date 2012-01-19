class Account < ActiveRecord::Base
  devise :token_authenticatable, :rememberable, :trackable
  before_save :ensure_authentication_token
  
  validates_presence_of :application_id

  attr_accessible :remember_me, :phone_number, :field_name, :consume_phone_number, :application_id, :permitted_phone_numbers
  
  has_many :menu_options, :dependent => :destroy
  
  # Builds the message options that is available for the account.
  # For example, #0 for menu screen
  #              #1 for information about objectA (e.g. outage)
  #              #2 for information about objectA
  def text_message_options
    # Get menu options
    menu_options = self.menu_options.all(:order => "name DESC")
    options = {}
    options["#0"] = ["menu",""]
    
    menu_options.each_with_index do |option, index|
      i = index+1
      options["#" + i.to_s] = [option.name, option.format]
    end
    
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
      raise ConsumeSms::GeneralTextMessageNotifierException, "Unable to get a response for url: #{url}"
    end
    
    object_names = []
    parsed_json.each do |x|
      object_names << x["mapping"]
    end
    
    object_names
  end
  
  # Gets the application name from the application id
  #
  # TODO: this will need to be replaced by getting the information from meta-data 
  # during the provision process instead.
  def self.get_application_name(application_id)
    url = "#{ENV['CHAMELEON_HOST']}/applications/#{application_id}.json"
    
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
    
    # Grab the human readable name
    parsed_json["slug"]
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

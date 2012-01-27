class Account < ActiveRecord::Base
  devise :token_authenticatable, :rememberable, :trackable
  before_save :ensure_authentication_token
  
  validates :application_id, :presence => true
  validates :consume_phone_number, :uniqueness => true

  attr_accessible :remember_me, :phone_number, :field_name, :consume_phone_number, :application_id, :permitted_phone_numbers
  
  has_many :menu_options, :dependent => :destroy
  has_many :outgoing_text_options, :dependent => :destroy
  
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
  

  # Gets object definition metadata using API call.
  def get_object_definition_metadata
    url = "#{ENV['CHAMELEON_HOST']}/applications/#{application_id}/api/versions/#{api_version}/objects.json"

    time = Time.now
    signed_secret = ConsumeSms::sign_secret(ENV['SHARED_SECRET'], application_id, time)
    response = ConsumeSms::connect_to_api(url, signed_secret)

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
 
    parsed_json
  end

  # Gets queryable field names using API call.
  def get_field_definition(object_definition_name)
    url = "#{ENV['CHAMELEON_HOST']}/applications/#{application_id}/api/versions/#{api_version}/objects/#{object_definition_name}.json"

    time = Time.now
    signed_secret = ConsumeSms::sign_secret(ENV['SHARED_SECRET'], application_id, time)
    response = ConsumeSms::connect_to_api(url, signed_secret)

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

    parsed_json
  end
  
  # Gets object definition names for an application
  def get_object_definition_mappings
    consumer = ConsumeSms::Consumer.new(self)
    parsed_json = get_object_definition_metadata

    object_names = []
    parsed_json.each do |x|
      object_names << x[0].downcase
    end
    
    object_names
  end
  
  def self.find_by_consume_phone_number(phone_number)
    Account.find_by_consume_phone_number(phone_number)
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
    available_phone_number
  end
  
  def self.get_used_phone_numbers
    Account.all.map {|x| x.consume_phone_number }
  end
  
  def self.generate_secure_parameters
    timestamp = Time.now.to_i
    application_id = @account.application_id
    {timestamp: timestamp.to_s, application_id: application_id, anypresence_auth: Digest::SHA1.hexdigest("#{ENV['SHARED_SECRET']}-#{application_id}-#{timestamp}") } 
  end

end

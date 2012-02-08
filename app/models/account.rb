class Account < ActiveRecord::Base
  NUM_ENTRIES = 4
  TWILIO_SMS_CHAR_PAGE_SIZE = 150
      
  devise :token_authenticatable, :rememberable, :trackable
  before_save :ensure_authentication_token
  
  validates :application_id, :presence => true
  validates :consume_phone_number, :uniqueness => true

  attr_accessible :remember_me, :phone_number, :field_name, :consume_phone_number, :application_id, :extension_id, :api_host
  
  has_many :menu_options, :dependent => :destroy
  has_many :outgoing_text_options, :dependent => :destroy
  has_one :bulk_text_phone_number, :dependent => :destroy
  
  # Builds the message options that is available for the account.
  # For example, #0 for menu screen
  #              #1 for information about objectA (e.g. outage)
  #              #2 for information about objectA
  def text_message_options
    # Get menu options
    menu_options = self.menu_options.where(:type => "MenuOption").all(:order => "name DESC")
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
    url = "#{api_host}/applications/#{application_id}/api/versions/#{api_version}/objects.json"

    time = Time.now
    signed_secret = ConsumeSms::sign_secret(ENV['SHARED_SECRET'], application_id, time)
    response = ConsumeSms::connect_to_api(url, signed_secret.merge(:add_on_id => self.extension_id))

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

  # Gets field names using API call.
  def get_field_definition_mappings(object_definition_name)
    url = "#{api_host}/applications/#{application_id}/api/versions/#{api_version}/objects/#{object_definition_name}.json"

    time = Time.now
    signed_secret = ConsumeSms::sign_secret(ENV['SHARED_SECRET'], application_id, time)
    response = ConsumeSms::connect_to_api(url, signed_secret.merge(:add_on_id => self.extension_id))

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

    attribute_names = []
    parsed_json.each do |object_definition|
      field_definitions = object_definition["field_definitions"]
      field_definitions.each do |field_definition|
        attribute_names << field_definition["name"]
      end
    end
    
    MenuOption::build_liquid_drop_class(object_definition_name, parsed_json[0]["field_definitions"])
    
    attribute_names
  end
  
  # Gets object definition names for an application
  def get_object_definition_mappings
    consumer = ConsumeSms::Consumer.new(self)
    parsed_json = get_object_definition_metadata

    object_names = []
    parsed_json.each do |object_definition|
      object_names << object_definition["name"].downcase
    end
    object_names
  end
  
  def object_instances_as_sms(object_name, format)
    msg_for_client = object_instances(object_name, format)
    out_message = Message::paginate_text(msg_for_client.join("\n"), TWILIO_SMS_CHAR_PAGE_SIZE)
  end  
  
  # Gets object instances.
  #
  # TODO: may want to sort in desc order to pick of last items.
  def object_instances(object_name, format)
    # Access the latest version.
    url = "#{api_host}/applications/#{application_id}/api/versions/latest/objects/#{object_name}/instances.json?order_desc=created_at"
    time = Time.now
    signed_secret = ConsumeSms::sign_secret(ENV['SHARED_SECRET'], self.application_id, time)
    response = ConsumeSms::connect_to_api(url, signed_secret.merge(:add_on_id => self.extension_id))
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
        msg_for_client << MenuOption::parse_format_string(format, object_name, x).to_s
    end
    msg_for_client
  end
  
  def self.find_by_consume_phone_number(phone_number)
    Account.find_by_consume_phone_number(phone_number)
  end
  
  # Gets the first available phone number if any.
  # An available phone number must be a number in Twilio that we are not using and
  # it must not have an SMS_URL associated with it.
  def self.phone_number_used(twilio_owned_numbers, used_numbers)
    available_phone_number = nil
    twilio_owned_numbers.each do |x|
      if x.sms_url.empty? && !used_numbers.include?(x.phone_number)
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

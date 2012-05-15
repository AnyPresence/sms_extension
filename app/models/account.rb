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
  
  class << self
    def find_by_consume_phone_number(phone_number)
      Account.find_by_consume_phone_number(phone_number)
    end
  
    # Gets the first available phone number if any.
    # An available phone number must be a number in Twilio that we are not using and
    # it must not have an SMS_URL associated with it.
    def phone_number_used(twilio_owned_numbers, used_numbers)
      available_phone_number = nil
      twilio_owned_numbers.each do |x|
        if x.sms_url.empty? && !used_numbers.include?(x.phone_number)
          available_phone_number = x.phone_number
          break
        end
      end
      available_phone_number
    end
  
    def get_used_phone_numbers
      Account.all.map {|x| x.consume_phone_number }
    end
  
    def generate_secure_parameters
      timestamp = Time.now.to_i
      application_id = @account.application_id
      {timestamp: timestamp.to_s, application_id: application_id, anypresence_auth: Digest::SHA1.hexdigest("#{ENV['SHARED_SECRET']}-#{application_id}-#{timestamp}") } 
    end
  end
  
  # Build an AnypresenceExtension client.
  def ap_client(*adhoc_api_version)
    version = adhoc_api_version.empty? ? 'latest' : adhoc_api_version[0]
    @ap_client ||= AnypresenceExtension::Client.new(self.api_host, self.api_token, self.application_id, version)
  end
  
  # Builds the message options that is available for the account.
  # For example, #0 for menu screen
  #              #1 for information about objectA (e.g. outage)
  #              #2 for information about objectA
  def text_message_options
    # Get menu options
    menu_options = self.menu_options.where(:type => "MenuOption").all(:order => "name DESC")
    options = {}
    options["#0"] = ["menu","", ""]
    
    menu_options.each_with_index do |option, index|
      i = index+1
      name = option.display_name.blank? ? option.name : option.display_name
      options["#" + i.to_s] = [name, option.name, option.format]
    end
    
    options
  end

  # Gets object definition metadata using API call.
  def object_definition_metadata
    response = ap_client(self.api_version).metadata.fetch
    json_decode_response(ap_client.url, response)
  end

  # Gets field names using API call.
  def field_definition_mappings(object_definition_name)
    response = ap_client(self.api_version).metadata(object_definition_name).fetch
    parsed_json = json_decode_response(ap_client.url, response)

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
  def object_definition_mappings
    parsed_json = object_definition_metadata

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
  def object_instances(object_name, format, opts={})
    # Accesses a page of the latest version.
    response = ap_client(self.api_version).data(object_name)
    
    msg_for_client = []
    count = 0
    current_page = 1
    
    max_entries = opts[:max_entries].nil? ? NUM_ENTRIES : opts[:max_entries]
    
    while true
      response = ap_client.resource.fetch
      if response.to_json.empty?
        break
      end
      parsed_json = json_decode_response(ap_client.url, response)     

     
      parsed_json.each do |x|
          break if (count == max_entries && opts[:query] != "all")
          count += 1
          Rails.logger.info "Parsed json: " + x.inspect
          msg_for_client << MenuOption::parse_format_string(format, object_name, x).to_s
      end
      
      if opts[:query] == "all"
        ap_client.resource.next_page
      else
        break
      end
    end
    msg_for_client
  end

private
  def json_decode_response(url, response)
    parsed_json = []
    case response.status
    when 200
      begin
        parsed_json = ActiveSupport::JSON.decode(response.body)
      rescue MultiJson::DecodeError
        raise ConsumeSms::GeneralTextMessageNotifierException, "Unable to decode the JSON message: #{url}"
      end
    when 301
      raise ConsumeSms::GeneralTextMessageNotifierException, "Unexpected redirection occurred: #{url}"
    else
      raise ConsumeSms::GeneralTextMessageNotifierException, "Unable to get a response: #{url}"
    end
    parsed_json
  end

end

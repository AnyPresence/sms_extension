
module SmsExtension
  class Account
    include ActiveModel::MassAssignmentSecurity
    include Mongoid::Document
    include Mongoid::Timestamps
  
    # Phone number to send text out to
    field :phone_number, type: String
    
    # From phone number that sends out the text
    field :from_phone_number, type: String
    
    field :field_name, type: String
    
    # Phone number to consume text
    field :consume_phone_number, type: String
    
    # Outgoing message formatted parsed by Liquid template
    field :outgoing_message_format, type: String
    
    # Twilio account sid
    field :twilio_account_sid, type: String
    
    # Twilio auth token
    field :twilio_auth_token, type: String
  
    NUM_ENTRIES = 4
    TWILIO_SMS_CHAR_PAGE_SIZE = 150

    validates :consume_phone_number, :uniqueness => true

    attr_accessible :phone_number, :field_name, :consume_phone_number, :from_phone_number, :outgoing_message_format, :twilio_account_sid, :twilio_auth_token

    has_many :menu_options, :class_name => "SmsExtension::MenuOption", :dependent => :destroy
    has_many :outgoing_text_options, :class_name => "SmsExtension::OutgoingTextOption", :dependent => :destroy

    # Builds the message options that is available for the account.
    # For example, #0 for menu screen
    #              #1 for information about objectA (e.g. outage)
    #              #2 for information about objectA
    def text_message_options
      # Get menu options
      menu_options = self.menu_options.where(:type => "MenuOption").all.order_by([:name, :desc])
      options = {}
      options["#0"] = ["menu",""]
  
      menu_options.each_with_index do |option, index|
        i = index+1
        options["#" + i.to_s] = [option.option_name, option.option_format]
      end
  
      options
    end

  private

  end
end

module SmsExtension
  class Account
    include Mongoid::Document
    include Mongoid::Timestamps
    
    field :phone_number, type: String
    field :field_name, type: String
    field :application_id, type: String
    field :consume_phone_number, type: String
    field :application_id, type: String
    
    NUM_ENTRIES = 4
    TWILIO_SMS_CHAR_PAGE_SIZE = 150
  
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

  private

  end
end

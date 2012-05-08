module SmsExtension
  class OutgoingTextOption < MenuOption
    include Mongoid::Document
    include Mongoid::Timestamps
    
    field :option_name, type: String
    field :option_format, type: String
    
    belongs_to :account, :class_name => "SmsExtension::Account"

    attr_accessible :build_text
  
    # Builds the outgoing text message.
    def build_text(object_name, attr_map)
      MenuOption::parse_format_string(self.option_format, object_name, attr_map)
    end
  end
end
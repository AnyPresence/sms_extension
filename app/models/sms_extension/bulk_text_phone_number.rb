module SmsExtension
  class BulkTextPhoneNumber < MenuOption
    include Mongoid::Document
    include Mongoid::Timestamps
    
    field :option_name, type: String
    field :option_format, type: String
    
    belongs_to :account, :class_name => "SmsExtension::Account"
  end
end

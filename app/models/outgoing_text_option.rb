class OutgoingTextOption < ActiveRecord::Base
  belongs_to :account
  
  validates :name, :presence => true, :uniqueness => true
  validates :format, :presence => true
    
  # Builds the outgoing text message.
  def build_text(attr_map)
    MenuOption::parse_format_string(format, attr_map)
  end
end

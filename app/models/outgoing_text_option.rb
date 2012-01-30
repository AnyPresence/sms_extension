class OutgoingTextOption < ActiveRecord::Base
  belongs_to :account
  
  validates :name, :presence => true
  validates :format, :presence => true
  
  attr_accessible :name, :format, :build_text
  
  # Builds the outgoing text message.
  def build_text(attr_map)
    MenuOption::parse_format_string(self.format, attr_map)
  end
end

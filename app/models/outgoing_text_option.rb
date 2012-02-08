class OutgoingTextOption < MenuOption
  attr_accessible :build_text
  
  # Builds the outgoing text message.
  def build_text(object_name, attr_map)
    MenuOption::parse_format_string(self.format, object_name, attr_map)
  end
end

class MenuOption < ActiveRecord::Base
  belongs_to :account
  
  validates :name, :presence => true, :uniqueness => true
  validates :format, :presence => true
  
  # Parse format string from menu options
  # The input string uses the Liquid template format, e.g. "Outage: {{title}} : {{description}}".
  # 'title' and 'description' are attributes for the 'outage' object.
  # If the attributes for a particular outage object are: title => "Widespread Outage", description => "Around D.C. area."
  # Then the rendered text should be "Outage: Widespread Outage : Around D.C. area".
  #
  # Note: more interesting functionality of Liquid will be used in few iterations.
  def self.parse_format_string(format, attr_map)
    # TODO: Liquid should be able to grab these {{string}}...
    tokenized = format.scan(/\{\{.*?\}\}/)
    params = []
    tokenized.each {|x| params << x.sub("{{","").sub("}}", "")}
    liquid_template_map = {}
    params.each do |x| 
      liquid_template_map[x] = attr_map[x] ? attr_map[x] : "undefined"
    end
    
    Liquid::Template.parse(format).render(liquid_template_map)
  end
end

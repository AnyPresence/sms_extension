require 'liquid'

module SmsExtension
  class MenuOption
    include Mongoid::Document
    include Mongoid::Timestamps

    field :option_name, type: String
    field :option_format, type: String  
    field :type, type: String   

    belongs_to :account, :class_name => "SmsExtension::Account"
  
    validates :option_name, :presence => true
    validates :option_format, :presence => true

    attr_accessible :option_name, :option_format
  
    # Parse format string from menu options
    # The input string uses the Liquid template format, e.g. "Outage: {{title}} : {{description}}".
    # 'title' and 'description' are attributes for the 'outage' object.
    #   If the attributes for a particular outage object are: title => "Widespread Outage", description => "Around D.C. area."
    #   Then the rendered text should be "Outage: Widespread Outage : Around D.C. area".
    def self.parse_format_string(format, object_name, decoded_json)
      klass = self.build_liquid_drop_class(object_name, decoded_json.keys)
      Rails.logger.info "Decoded json: #{decoded_json.inspect}"
      # Set instance variables for klass from decoded json
      klass_instance = klass.new(decoded_json)
    
      vars = klass_instance.instance_variables.map {|v| v.to_s[1..-1] }
      liquid_hash = {}
      vars.each do |v|
        liquid_hash[v] = klass_instance.send v
      end
    
      liquid_hash[object_name.downcase] = klass_instance
      Liquid::Template.parse(format).render(liquid_hash)
    end

    # Builds a liquid drop class from the object_name
    def self.build_liquid_drop_class(object_name, fields)
      klass = Class.new(Liquid::Drop) do
        define_method(:initialize) do |arg|
          arg.each do |k,v|
            instance_variable_set("@#{k}", v)
          end
        end
      
        fields.each do |field|
          define_method("#{field}=") do |arg|
            instance_variable_set("@#{field}", arg)
          end
          define_method field do
            instance_variable_get("@#{field}")
          end
        end
      end
      klass
    end
  
  end
end
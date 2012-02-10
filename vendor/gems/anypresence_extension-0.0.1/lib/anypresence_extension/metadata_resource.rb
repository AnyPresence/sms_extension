module AnypresenceExtension
  class MetadataResource < AnypresenceExtension::Resource
    attr_reader :object, :uri
    
    def initialize(client, object=nil)
      @client = client
      object = object unless object.nil?
      @uri = object.nil? ? "objects.json" : "objects/#{object}.json"
    end
    
  end
end
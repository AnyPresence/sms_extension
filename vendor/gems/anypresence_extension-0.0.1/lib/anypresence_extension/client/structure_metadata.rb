module AnypresenceExtension
  class Client
    module StructureMetadata
      def fetch_metadata(object)
        fetch("objects/#{object}.json")
      end
      
      def fetch_available_objects
        fetch("objects.json")
      end
    end
  end
end
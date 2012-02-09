module AnypresenceExtension
  class Client
    module StructureMetadata
      def fetch_metadata(object)
        fetch("objects/#{object}.json")
      end
    end
  end
end
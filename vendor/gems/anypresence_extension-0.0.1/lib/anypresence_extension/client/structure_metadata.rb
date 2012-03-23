require 'anypresence_extension/metadata_resource'

module AnypresenceExtension
  class Client
    module StructureMetadata
      def metadata(object=nil)
        @resource = MetadataResource.new(self, object)
      end
    end
  end
end
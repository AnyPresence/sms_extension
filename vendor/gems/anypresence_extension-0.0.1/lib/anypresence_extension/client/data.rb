require 'anypresence_extension/pageable'
require 'anypresence_extension/data_resource'

module AnypresenceExtension
  class Client
    module Data
      # Fetches the instances for +object+
      def data(object, opts={})
        @resource = DataResource.new(self, object, opts)
      end
    end
  end
end
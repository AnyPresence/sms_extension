module AnypresenceExtension
  class Client
    module Data
      def fetch_data(object, opts={})
        sort_order = "order_desc"
        orderable_object = "created_at"
        unless opts.nil?
          sort_order = !opts[:sort_order].nil? ? opts[:sort_order] : sort_order
          orderable_object = !opts[:orderable_object].nil? ? opts[:orderable_object] : orderable_object
        end
        fetch("objects/#{object}/instances.json?#{sort_order}=#{orderable_object}")
      end
    end
  end
end

module AnypresenceExtension
  # This class respresents +object_instances+ from AnyPresence's API. There may be lots of data and
  # so it should be pageable. 
  class DataResource < AnypresenceExtension::Resource
    include Pageable
    
    attr_reader :object, :uri, :uri_without_get_param
    
    def initialize(client, object, opts={})
      @client = client
      @object = object unless object.nil?
      
      @sort_order = "order_desc"
      @orderable_object = "created_at"
      unless opts.nil?
        @sort_order = !opts[:sort_order].nil? ? opts[:sort_order] : @sort_order
        @orderable_object = !opts[:orderable_object].nil? ? opts[:orderable_object] : @orderable_object
      end
      
      # Post parameter hash
      @params = {}
      
      update_uri
    end
    
    def update_uri
      @uri_without_get_param = "objects/#{@object}/instances.json"
      @uri = @uri_without_get_param + "?page=#{current_page}&#{@sort_order}=#{@orderable_object}&per_page=#{per_page}"
    end
    
    def set_post_params(param)
      @params.merge(param)
    end
  end
end
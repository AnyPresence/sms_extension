module AnypresenceExtension
  class Resource
    def fetch
      if @client.nil?
        raise "Client must be set..."
      end
      
      @client.fetch
    end
  end
end
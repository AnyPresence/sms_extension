require 'anypresence_extension/errors'
require 'anypresence_extension/client/structure_metadata'
require 'anypresence_extension/client/data'

module AnypresenceExtension
  class Client
    include AnypresenceExtension::Client::StructureMetadata
    include AnypresenceExtension::Client::Data
    
    attr_reader :application_id, :api_version
    
    def initialize(api_host, api_token, application_id, api_version='latest')
      @base_uri = api_host
      @api_token = api_token
      @application_id = application_id
      @api_version = api_version
      
      setup_connection
    end
    
private
    # Perform some basic setup
    def setup_connection
      @base_uri ||= "http://localhost:5000"
      @base_uri =  @base_uri + "/applications/#{@application_id}/api/versions/#{@api_version}/"
    end
    
    # Actually fetch the resource via api calls
    def fetch(uri)
      url = "#{@base_uri}#{uri}"
      p url
      response = connect_to_api(url, {:api_token => @api_token})
      case response
      when Net::HTTPSuccess
        return response
      when Net::HTTPRedirection
        raise AnypresenceExtension::RequestError, "Unexpected redirection occurred for url: #{url}"
      else
        raise AnypresenceExtension::RequestError, "Unable to get a response for url: #{url}"
      end
    end
    
    # Connecto API and return a json response.
    def connect_to_api(url, *parameters)
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
    
      response = nil
      if uri.scheme == "https"
        http.use_ssl = true
        # This is temporary
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
      
      request = Net::HTTP::Get.new(uri.request_uri)
      @last_request = request
      request.set_form_data parameters[0] if !parameters.nil?
      response = http.request request
    end
  end
end
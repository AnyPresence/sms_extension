require 'faraday'
require 'multi_json'
require 'anypresence_extension/errors'
require 'anypresence_extension/client/structure_metadata'
require 'anypresence_extension/authenticatable'
require 'anypresence_extension/client/data'

module AnypresenceExtension

  class Client
    include AnypresenceExtension::Client::StructureMetadata
    include AnypresenceExtension::Client::Data
    include AnypresenceExtension::Authenticatable
    
    attr_reader :application_id, :api_version, :resource, :settings, :connection, :url
    
    def initialize(api_host, api_token, application_id, api_version='latest')
      @base_uri = api_host.strip unless api_host.nil?
      @api_token = api_token.strip unless api_token.nil?
      @application_id = application_id.strip unless application_id.nil?
      @api_version = api_version.strip unless api_version.nil?
      
      setup_connection
      
      uri = URI.parse(@base_uri)
    end
    
    def fetch
      ClientData.new(get(@resource.uri))
    end
    
    def create(params)
      post(@resource.uri_without_get_param, params)
    end
    
private
    # Perform some basic setup
    def setup_connection
      @base_uri ||= "http://localhost:5000"
      @base_uri = @base_uri + "/applications/#{@application_id}/api/versions/#{@api_version}/"
      
      connection({:user_agent => "Anypresence Extension"})
    end
    
    # Actually fetch the resource via api calls
    def get(uri)
      @url = "#{@base_uri}#{uri}"
      if resource.kind_of? DataResource 
        if  !@http_basic_creds.nil?
          response = @connection.get url, "AUTHORIZATION" => "Basic " + Base64::encode64("#{@http_basic_creds[:username]}:#{@http_basic_creds[:password]}")
        else
          response = @connection.get url
        end
      else
        response = @connection.get "#{@url}?api_token=#{@api_token}" 
      end
      
      response
    end
    
    def post(uri, params)
      @url = "#{@base_uri}#{uri}"
      response = @connection.post url, params
    end
    
    # Connect to API.
    def connection(options={})
      default_options = {
        :headers => {
          :accept => 'application/json',
          :user_agent => options[:user_agent],
        },
        :proxy => options[:proxy],
        :ssl => {:verify => false},
        :url => options.fetch(:endpoint, options[:endpoint]),
      }
      @connection ||= Faraday.new(default_options) do |builder|
        builder.use Faraday::Request::UrlEncoded  # convert request params as "www-form-urlencoded"
        builder.use Faraday::Response::Logger     # log the request to STDOUT
        builder.use Faraday::Adapter::NetHttp     # make http requests with Net::HTTP
        builder.adapter(:net_http)
      end
    end
    
    # This class encapsulates the response from Faraday to allow chaining such as:
    #   client.data('outage').fetch.to_json
    class ClientData
      def initialize(data)
        @data = data
      end
      
      def raw_response
        @data
      end
      
      def to_json
        MultiJson::decode(@data.body)
      end
      
      # TODO: define methods dynamically instead.
      def method_missing(sym, *args, &block)
        @data.send sym, *args, &block
      end
    end
  end
end
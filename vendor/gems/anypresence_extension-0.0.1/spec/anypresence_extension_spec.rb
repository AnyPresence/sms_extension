$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
require 'anypresence_extension'
require 'spec_helper.rb'

describe AnypresenceExtension::Client do
  before(:each) do 
    @client = AnypresenceExtension::Client.new("http://localhost:5000", '12345', 'outage-reporter')
  end
  
  it 'should setup a new client with api token' do
    @client.instance_variable_get('@api_token').should == '12345'
  end
  
  it 'should not have getter for @api_token' do
    expect { @client.api_token }.to raise_error
  end
  
  it 'should know to set a default api version to latest' do
    @client = AnypresenceExtension::Client.new("http://localhost:5000", '12345', 'some_application_id')
    @client.api_version == 'latest'
  end
  
  describe "fetch" do
    def structure_metadata
       %q([{"_id":"1","mapping":"outage","name":"Outage","slug":"outage"])
    end
    
    def available_objects
      %q([{"_id":"1","mapping":"outage","name":"Outage","slug":"outage"])
    end
    
    def object_instances
      %q([{"title":"Cleveland Abbe House","description":"1 customer affected.","latitude":"38.901444","longitude":"-77.046167","created_at":"2012-02-01"},
        {"title":"Outage","description":"Outage"}])
    end
    
    it 'should know how to get object instances' do
      VCR.use_cassette('list_object_instances', :erb => {:body => object_instances} ) do
        object_instances = @client.fetch_data('outage').fetch
        debugger
        object_instances.should =~ /1 customer affected/
      end
    end
    
    it "should be able to find objects in the metadata" do
      VCR.use_cassette('list_structure_metadata_for_outage_app', :erb => {:body => structure_metadata} ) do
        #object_names = @client.fetch_metadata('outage').body
        object_names = @client.fetch_metadata('outage').fetch
        object_names.should =~ /Outage/
      end
    end
    
    it "should be able to find all available object types" do
      VCR.use_cassette('list_available_objects_for_outage_app', :erb => {:body => available_objects} ) do
        object_names = @client.fetch_metadata.fetch
        object_names.should =~ /Outage/
      end
    end
    
    it "should be able to get object instances in pages" do
      VCR.use_cassette('list_object_instances', :erb => {:body => object_instances} ) do
        object_instances = @client.fetch_data('outage').fetch
        @client.resource.respond_to?(:page).should be_true
      end
    end
  end

end

describe AnypresenceExtension::DataResource do 
  before(:each) do 
    @client = AnypresenceExtension::Client.new("http://localhost:5000", '12345', 'outage-reporter')
  end
  
  def object_instances
    %q([{"title":"Cleveland Abbe House","description":"1 customer affected.","latitude":"38.901444","longitude":"-77.046167","created_at":"2012-02-01"},
      {"title":"Outage","description":"Outage"}])
  end
  
  it "should set initial page to 0" do
    VCR.use_cassette('list_object_instances', :erb => {:body => object_instances} ) do
      object_instances = @client.fetch_data('outage').fetch
      @client.resource.current_page.should == 0
      
      @client.resource.next_page.current_page.should == 1
      @client.resource.next_page.fetch.should_not be_empty
    end
  end
end


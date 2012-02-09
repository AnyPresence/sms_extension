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
       %q([{"_id":"1","application_definition_id":"1","code_friendly_name":"Gen__Outage","composite_key_delimiter":"-",
       "created_at":"2012-02-01T13:46:52-05:00","default_sort_field":null,"default_sort_order":"Ascending",
       "field_definitions":[{"_id":"1a","auto":true,"created_at":null,"editable":false,"key":true,"mapping":"_id","name":"id",
       "queryable":true,"required":false,"type":"String","updated_at":null},{"_id":"2",
       "auto":false,"created_at":"2012-02-01T13:46:52-05:00","editable":true,"key":false,"mapping":"title","name":"title",
       "queryable":true,"required":false,"type":"String","updated_at":"2012-02-01T13:46:52-05:00"},
       {"_id":"1b","auto":false,"created_at":"2012-02-01T13:46:52-05:00","editable":true,"key":false,"mapping":"description",
       "name":"description","queryable":true,"required":false,"type":"String","updated_at":"2012-02-01T13:46:52-05:00"},
       {"_id":"dd","auto":false,"created_at":null,"editable":false,"key":false,"mapping":"created_at",
       "name":"created_at","queryable":true,"required":false,"type":"Date","updated_at":null}],"mapping":"outage",
       "name":"Outage","slug":"outage","storage_interface_id":"4f","updated_at":"2012-02-02T10:44:29-05:00"}])
    end
    
    def object_instances
      %q([{"title":"Cleveland Abbe House","description":"1 customer affected.","latitude":"38.901444","longitude":"-77.046167","created_at":"2012-02-01"},
        {"title":"Outage","description":"Outage"}])
    end
    
    it 'should know how to get object instances' do
      VCR.use_cassette('list_object_instances', :erb => {:body => object_instances} ) do
        object_instances = @client.fetch_data('outage').body
        object_instances.should =~ /1 customer affected/
      end
    end
    
    it "should be able to find objects in the metadata" do
      VCR.use_cassette('list_structure_metadata_for_outage_app', :erb => {:body => structure_metadata} ) do
        object_names = @client.fetch_metadata('outage').body
        object_names.should =~ /Outage/
      end
    end
  end

end


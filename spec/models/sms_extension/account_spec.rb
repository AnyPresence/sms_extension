require 'spec_helper'

describe Account do
  describe "Build text message menu" do
    it "should know how to build menu options" do
      account = Factory.create(:account)
      options  = Factory.create(:menu_option, :name => 'department', :type => "MenuOption", :account => account)
      
      options = account.text_message_options
      debugger
      options["#0"][0].should == "menu"
      options["#1"][0].should == "department"
    end
  end
  
  describe "query for metadata" do
    before(:each) do
      @account = Factory.build(:account, :application_id => "outage-reporter")
    end
    
    def object_definition_mappings_response
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
    
    it "should be able to find objects in the metadata" do
      VCR.use_cassette('list_objects_for_outage_app', :erb => {:body => object_definition_mappings_response} ) do
        @account.api_version = "v4"
        object_names = @account.object_definition_metadata
        object_names[0].should include({"name" => "Outage", "mapping" => "outage"})
      end
    end
    
    it "should fail with 401 without an api_token" do
      VCR.use_cassette('list_objects_for_outage_app_unauthorized') do
        expect{ @account.object_definition_metadata }.to raise_error
      end
    end
  end
  
  describe "query for object instances" do
    
    def get_object_instances
      %q([{"title":"Cleveland Abbe House","description":"1 customer affected.","latitude":"38.901444","longitude":"-77.046167","created_at":"2012-02-01"},
        {"title":"Outage","description":"Outage"}])
    end
    
    it "should be able to find object instances" do 
      @account = Factory.build(:account, :application_id => "outage-reporter")
        VCR.use_cassette('list_object_instances', :erb => {:body => get_object_instances} ) do
          @account.api_version = "v4"
          outgoing_text_message = @account.object_instances("outage", "{{description}}")
          outgoing_text_message[0].should =~ /1 customer affected./
        end
    end
    
    it "should be able to use existing liquid filters" do 
      @account = Factory.build(:account, :application_id => "outage-reporter")
        VCR.use_cassette('list_object_instances', :erb => {:body => get_object_instances} ) do
          @account.api_version = "v4"
          outgoing_text_message = @account.object_instances("outage", "{{outage.description | upcase}}")
          outgoing_text_message[0].should =~ /1 CUSTOMER AFFECTED./
          
          outgoing_text_message = @account.object_instances("outage", "{% if outage.description == '1 customer affected.' %} Howdy {% endif %}")
          outgoing_text_message[0].should =~ /Howdy/
        end
    end
  end
  
  describe "validations" do 
    before(:each) do
      @consume_phone_number = "+16178613962"
      @account = Factory.create(:account, {:consume_phone_number => @consume_phone_number})
    end
    
    it "should know that 'consume_phone_number' must be unique" do
      other_account = Factory.build(:account, {:application_id => @account.application_id.to_s + "99", :consume_phone_number => @consume_phone_number})
      expect { other_account.save! }.should raise_error(ActiveRecord::RecordInvalid)
    end
  end
  
end

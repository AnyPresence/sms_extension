require 'spec_helper'

describe Account do
  describe "Build text message menu" do
    it "should know how to build menu options" do
      account = Factory.create(:account)
      Factory.create(:menu_option, :account => account)
      Factory.create(:menu_option, :name => 'department', :account => account)
      
      options = account.text_message_options
      options["#0"][0].should == "menu"
      options["#1"][0].should == "outage"
      options["#2"][0].should == "department"
    end
  end
  
  describe "query for metadata" do
    before(:each) do
      @account = Factory.build(:account)
    end
    
    def object_definition_mappings_response
        %q([{"name":"Outage", "mapping":"outage"}, {"name":"foo", "mapping":"bar"}])
    end
    
    it "should be able to find objects in the metadata" do
      VCR.use_cassette('list_objects_for_outage_app', :erb => {:body => object_definition_mappings_response} ) do
        @account.api_version = "v10"
        object_names = @account.get_object_definition_metadata
        object_names.should include({"name" => "Outage", "mapping" => "outage"})
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
          outgoing_text_message = @account.get_object_instances("outage", "{{description}}")
          outgoing_text_message[0].should =~ /Outage/
        end
    end
    
    it "should be able to use existing liquid filters" do 
      @account = Factory.build(:account, :application_id => "outage-reporter")
        VCR.use_cassette('list_object_instances', :erb => {:body => get_object_instances} ) do
          @account.api_version = "v4"
          outgoing_text_message = @account.get_object_instances("outage", "{{outage.description | upcase}}")
          outgoing_text_message[0].should =~ /OUTAGE/
          
          outgoing_text_message = @account.get_object_instances("outage", "{% if outage.description == 'Outage' %} Howdy {% endif %}")
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

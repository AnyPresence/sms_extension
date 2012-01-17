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
  
  describe "VCR recording" do
    before(:each) do
      @account = Factory.build(:account)
    end
    
    it "should have outage as an object definition in the list of objects" do
      VCR.use_cassette('list_objects_for_outage_app') do
        object_names = @account.get_object_definition_mappings('outage-reporter')
        
        object_names.should include("outage")
      end
    end
    
    it "should have get 'application name' from application_id" do
      VCR.use_cassette('get_application_name') do
        object_names = Account::get_application_name(@account.application_id)
        
        object_names.should include("outage-reporter")
      end
    end
    
  end
  
end

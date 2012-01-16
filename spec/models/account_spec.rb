require 'spec_helper'

describe Account do
  
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
  end
end

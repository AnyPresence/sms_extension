require 'spec_helper'

describe SmsExtension::Account do
  describe "Build text message menu" do
    it "should know how to build menu options" do
      account = FactoryGirl.create(:sms_extension_account)
      options  = FactoryGirl.create(:menu_option, :option_name => 'department', :type => "MenuOption", :account => account)
      
      options = account.text_message_options
      options["#0"][0].should == "menu"
      options["#1"][0].should == "department"
    end
  end
  
end

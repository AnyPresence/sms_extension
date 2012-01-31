require 'spec_helper'

describe "client provisions new account" do
  before(:each) do
    # create an account for testing
    @account = Factory.build(:account)   
  end
  
  def generate_secure_parameters
    timestamp = Time.now.to_i
    app_id = @account.application_id
    {timestamp: timestamp.to_s, application_id: app_id, anypresence_auth: Digest::SHA1.hexdigest("#{ENV['SHARED_SECRET']}-#{app_id}-#{timestamp}") } 
  end
  
  describe "provision new account" do
    it "should provision with valid secure parameter" do
      page.driver.post("/provision", generate_secure_parameters)
      doc = Hpricot(page.body)
      JSON.parse(doc.to_plain_text)["success"].should be_true
    end
  end
  
  describe "settings page" do 
    before(:each) do
      page.driver.header("X_AP_OBJECT_DEFINITION_NAME", "v2")
      page.driver.post("/provision", generate_secure_parameters)
    end
    
    it "should know how to update settings without filling in incoming phone number" do
      Twilio::REST::Client.any_instance.stub_chain(:incoming_phone_numbers, :create).and_return(true)
      page.driver.get("/settings", generate_secure_parameters)
      page.body.should match(/Please publish the application for more configuration options./)
      page.should_not have_content("Build outgoing text options")
      fill_in 'account[phone_number]', :with => '9789445741'
      
      click_button 'Update Account'
      
      page.should have_content 'Account updated'
    end
  end

end

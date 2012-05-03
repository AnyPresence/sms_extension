require 'spec_helper'

describe SmsExtension::TexterController do
  
  def mock_twilio_client
    twilio_client = double('twilio')
  end
  
  def mock_twilio_account
    twilio_client = double('account')
  end
   
  def generate_secure_parameters
    timestamp = Time.now.to_i
    app_id = @account.application_id
    {timestamp: timestamp.to_s, application_id: app_id, anypresence_auth: Digest::SHA1.hexdigest("#{ENV['SHARED_SECRET']}-#{app_id}-#{timestamp}") } 
  end
  
  describe 'GET settings' do
    before(:each) do
      # create an account for testing
      @account = Factory.create(:account)
      sign_in @account     
    end  
          
    it "should render settings with valid parameters" do
        secure_parameters = generate_secure_parameters
        get :settings, :application_id => secure_parameters[:application_id], :anypresence_auth => secure_parameters[:anypresence_auth], :timestamp => secure_parameters[:timestamp]
        response.should render_template "settings"
    end
    
    it "should tell user to publish application for more configuration options" do
        secure_parameters = generate_secure_parameters
        get :settings, :application_id => secure_parameters[:application_id], :anypresence_auth => secure_parameters[:anypresence_auth], :timestamp => secure_parameters[:timestamp]
        response.should render_template "settings"
    end
  end
  
  describe 'PUT settings' do
    before(:each) do
      @account = Factory.create(:account)
      sign_in @account     
    end  
          
    it "should update account with new phone number" do
        #secure_parameters = generate_secure_parameters
        new_phone_number = "9789445742"
        new_field_name = "description"
        subject.current_account.consume_phone_number = nil
        put :settings, :commit => "Update Account", :account => {:phone_number => new_phone_number, :field_number => new_field_name}
        subject.current_account.phone_number.should == new_phone_number
    end
    
    it "should update account with new consume_phone_number" do
        new_phone_number = "9789445742"
        new_field_name = "description"
        
        twilio_client = mock_twilio_client
        twilio_account = mock_twilio_account
        
        Twilio::REST::Client.should_receive(:new).with(any_args()).and_return(twilio_client)
        twilio_client.stub(:account).and_return(twilio_account)
        twilio_account.stub_chain(:incoming_phone_numbers, :list).and_return([])
        twilio_account.stub_chain(:incoming_phone_numbers, :create).with(any_args()).and_return(true)
        subject.current_account.consume_phone_number = nil
        put :settings, :commit => "Update Account", :account => {:phone_number => new_phone_number, :field_number => new_field_name, :consume_phone_number => "9783194410"}
        response.body.should redirect_to(:settings)
    end
  end
  
  describe "setup extensions" do
    before(:each) do
      @account = Factory.build(:account)
    end
    
    describe 'provision' do
      it "should update old account that exists already" do
        @account0 = Factory.create(:account)
        sign_in @account0
        Account.where(:application_id => @account0.application_id).size.should == 1
        
        secure_parameters = generate_secure_parameters
        
        post :provision, :application_id => @account0.application_id, :anypresence_auth => secure_parameters[:anypresence_auth], :timestamp => secure_parameters[:timestamp]
        parsed_body = JSON.parse(response.body)
        parsed_body["success"].should == true
        
        Account.all.size.should == 1
      end
      
      it "should login successfully" do
        secure_parameters = generate_secure_parameters
        
        post :provision, :application_id => secure_parameters[:application_id], :anypresence_auth => secure_parameters[:anypresence_auth], :timestamp => secure_parameters[:timestamp]
        parsed_body = JSON.parse(response.body)
        parsed_body["success"].should == true    
      end
      
      it "should login unsuccessfully with different application_id" do
        secure_parameters = generate_secure_parameters
        
        app_id = secure_parameters[:application_id].to_i + 1;
        app_id = app_id.to_s
        
        post :provision, :application_id => app_id, :anypresence_auth => secure_parameters[:anypresence_auth], :timestamp => secure_parameters[:timestamp]
        parsed_body = JSON.parse(response.body)
        parsed_body["success"].should == false 
      end
      
      it "should know to save the current api version information" do
        secure_parameters = generate_secure_parameters
        
        request.env['X_AP_API_VERSION'] = "v1"
        post :provision, :application_id => secure_parameters[:application_id], :anypresence_auth => secure_parameters[:anypresence_auth], :timestamp => secure_parameters[:timestamp]
        parsed_body = JSON.parse(response.body)
        parsed_body["success"].should == true
        Account.first.api_version.should == "v1"
      end
    end
  end
  
  describe "publish" do
    it "should require authentication" do
      post :publish
      response.status.should_not == 200
    end
  end
  
  describe "publish new api version" do 
    before(:each) do
      @account = Factory.create(:account, :api_version => "v1")
      sign_in @account
    end
  
    it "should use the new api version" do
      secure_parameters = generate_secure_parameters
      request.env['X_AP_API_VERSION'] = 'v2'
      post :publish, :application_id => secure_parameters[:application_id], :anypresence_auth => secure_parameters[:anypresence_auth], :timestamp => secure_parameters[:timestamp]
       
      parsed_body = JSON.parse(response.body)
      parsed_body["success"].should == true
      subject.current_account.api_version.should == "v2"
    end
    
    it "should display error without api_version as post parameter" do
      post :publish
      
      parsed_body = JSON.parse(response.body)
      parsed_body["success"].should == false
    end
  end
    
  describe 'perform text' do
    before(:each) do
      @account = Factory.create(:fully_assembled_account) 
      sign_in @account
    end

    it "should text sucessfully when @object_definition_name is available" do
      twilio_client = mock_twilio_client
      twilio_account = mock_twilio_account
      subject.current_account.phone_number = "+16178613962" # a state rejection number
      Twilio::REST::Client.should_receive(:new).with(any_args()).and_return(twilio_client)

      twilio_client.stub(:account).and_return(twilio_account)
      sms = double('sms')
      twilio_account.stub_chain(:sms,:messages,:create).and_return(sms)
      
      controller.should_receive(:find_object_definition_name)
      controller.instance_variable_set(:@object_definition_name, 'Outage')
      
      post :text
      
      parsed_body = JSON.parse(response.body)
      parsed_body["success"].should == true
    end

    it "should text unsuccessfully with json error message when there's no @object_defintion_name defined" do
      post :text
      parsed_body = JSON.parse(response.body)
      parsed_body["success"].should == false      
    end
    
    it "should text unsucessfully without phone number" do
      subject.current_account.phone_number = nil;
      post :text
      response.body.should == "Not yet set up!"
    end
         
  end
  
  describe 'perform sms consumption' do
    before(:each) do
      # create an account for testing
      @consume_phone_number = "6178613962"
      @account = Factory.create(:account, {:consume_phone_number => @consume_phone_number})
      sign_in @account
    end     
     
    it "should consume and text successfully" do
      Message.any_instance.stub(:save).and_return(true)
      twilio_client = mock_twilio_client
      twilio_account = mock_twilio_account
      subject.current_account.phone_number = "+19783194410" # a state rejection number
      
      Twilio::REST::Client.should_receive(:new).with(any_args()).and_return(twilio_client)

      twilio_client.stub(:account).and_return(twilio_account)
      sms = double('sms')
      twilio_account.stub_chain(:sms, :messages, :create).and_return(sms)
      
      post :consume, :SmsMessageSid => '1234', :AccountSid => '1234', :Body => '#1', :From => '+19783194410', :To => @consume_phone_number
      
      parsed_body = JSON.parse(response.body)
      parsed_body["success"].should == true
    end
    
    it "should know to send default error message for a phone number it can't find an account for" do
      Message.any_instance.stub(:save).and_return(true)
      twilio_client = mock_twilio_client
      twilio_account = mock_twilio_account
      subject.current_account.phone_number = "+19783194410"
      
      Twilio::REST::Client.should_receive(:new).with(any_args()).and_return(twilio_client)

      twilio_client.stub(:account).and_return(twilio_account)
      sms = double('sms')
      
      twilio_account.stub_chain(:sms, :messages, :create).with(any_args())  do |x| 
        x[:body].should == "The extension is not configured for your account." 
      end
      
      # Post with different 'To' phone number
      post :consume, :SmsMessageSid => '1234', :AccountSid => '1234', :Body => '0', :From => '+19783194410', :To => "+16179999999"

      parsed_body = JSON.parse(response.body)
      parsed_body["success"].should == true
    end
  end
 
end
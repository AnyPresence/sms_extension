require 'spec_helper'
require 'ap/sms_extension/sms'

describe AP::SmsExtension::Sms::Consumer do
  
  def setup_twilio
    twilio_client = double('twilio_client')
    Twilio::REST::Client.should_receive(:new).with(any_args()).and_return(twilio_client)
    @twilio_account = double('twilio_account')
    twilio_client.should_receive(:account).and_return(@twilio_account) 
  end
  
  it "should fail when sending without 'from' number" do
    expect { AP::SmsExtension::Sms::Consumer.send_sms }.should raise_error
  end
  
  it "should succeed when sending with correct parameters" do
    setup_twilio
    @twilio_account.stub_chain(:sms, :messages, :create).with(any_args()).and_return(true)
    
    AP::SmsExtension::Sms::Consumer.send_sms(:from => "13392192167", :to => "13392192167", :body => "hello world")
  end
  
  describe "configure" do 
    it "should configure unsuccessfully without parameters" do
      expect { AP::SmsExtension::Sms::config_account }.should raise_error
    end
    
    it "should configure successfully with parameters" do
      ENV['SMS_EXTENSION_TWILIO_ACCOUNT_SID'] = "1234" 
      ENV['SMS_EXTENSION_TWILIO_AUTH_TOKEN'] = "5678"
      AP::SmsExtension::Sms::config_account(:phone_number => "13392192167", :consume_phone_number => "13392192167")
      ::SmsExtension::Account.all.size.should == 1
      
      account = ::SmsExtension::Account.first
      account.twilio_account_sid.should_not be_nil
      account.twilio_auth_token.should_not be_nil
    end
    
    it "should configure successfully with menu option parameters for incoming sms" do
      consume_options = [{:option_name => "outage", :option_format => "noo...outage!!"}, {:option_name => "store", :option_format => "stores!!"}]
      AP::SmsExtension::Sms::config_account(:phone_number => "13392192167", :consume_phone_number => "13392192167", :field => "name", :menu_options => consume_options)
      ::SmsExtension::Account.all.size.should == 1
      ::SmsExtension::Account.first.menu_options.all.size.should == 2
    end
  
  end
  
  describe "text" do
    before(:each) do
      @account = FactoryGirl.create(:sms_extension_account)
    end
    
    def params
      %q({"title":"Cleveland Abbe House","phone_number":"1234567","description":"1 customer affected.","latitude":"38.901444","longitude":"-77.046167","created_at":"2012-02-01"})
    end
    
    it "should know how to create an instance of Twilio" do
      @account.twilio_account_sid = "1234"
      @account.twilio_auth_token = "5678"
      consumer = AP::SmsExtension::Sms::Consumer.new(@account)
      twilio_account = double('twilio_account')
      Twilio::REST::Client.should_receive(:new).with(@account.twilio_account_sid, @account.twilio_auth_token).and_return(twilio_account)
      twilio_account.stub(:account)
      consumer.twilio_account
    end
    
    it "should know how to text" do
      setup_twilio
      format = "hello world" 
      @twilio_account.stub_chain(:sms, :messages, :create).with do |arg|
        arg[:body].should eq(format)
      end
      
      consumer = AP::SmsExtension::Sms::Consumer.new(@account)
      parsed_json = ActiveSupport::JSON.decode(params)
      options = {:from_phone_number => "13392192167", :phone_number => "13392192167"}
      consumer.text(options, parsed_json, "outage", format)
    end
    
    it "should know how to text with interpolated variables in message" do
      setup_twilio
      format = "hello, {{title}}" 
      @twilio_account.stub_chain(:sms, :messages, :create).with do |arg|
        arg[:body].should eq("hello, Cleveland Abbe House")
      end
      
      consumer = AP::SmsExtension::Sms::Consumer.new(@account)
      parsed_json = ActiveSupport::JSON.decode(params)
      options = {:from_phone_number => "13392192167", :phone_number => "13392192167"}
      consumer.text(options, parsed_json, "outage", format)
    end
    
    it "should know how to interpolate variables in phone number fields" do
      setup_twilio
      from_phone_number = "{{phone_number}}"
      phone_number = "{{phone_number}} kungfu"
      @twilio_account.stub_chain(:sms, :messages, :create).with do |arg|
        arg[:from].should eq("1234567")
        arg[:to].should eq("1234567 kungfu")
      end
      
      consumer = AP::SmsExtension::Sms::Consumer.new(@account)
      parsed_json = ActiveSupport::JSON.decode(params)
      options = {:from_phone_number => from_phone_number, :phone_number => phone_number}
      consumer.text(options, parsed_json, "outage", "something")
    end
    
    it "should use SMS_EXTENSION_TWILIO_FROM_SMS_NUMBER for from number if it's not set on account" do
      ENV['SMS_EXTENSION_TWILIO_FROM_SMS_NUMBER'] = "1234"
      ::SmsExtension::Account.any_instance.stub(:from_phone_number).and_return(nil)
      thing = double('thing')
      thing.stub(:attributes).and_return({:fake => "fake"})
      options = HashWithIndifferentAccess.new
      AP::SmsExtension::Sms::Consumer.any_instance.should_receive(:text).with do |arg|
        arg[:from_phone_number].should eq(ENV['SMS_EXTENSION_TWILIO_FROM_SMS_NUMBER'])
      end
      Class.new.extend(AP::SmsExtension::Sms).sms_perform(thing, options)
    end
    
    it "should use 'outgoing message format' passed into hash if it's provided" do
      thing = double('thing')
      thing.stub(:attributes).and_return({:fake => "fake"})
      options = HashWithIndifferentAccess.new({:from_phone_number => "1234", :phone_number => "5678", :outgoing_message_format => "hotdog"})
      AP::SmsExtension::Sms::Consumer.any_instance.should_receive(:text).with(options, anything(), anything(), "hotdog").and_return(true)
      Class.new.extend(AP::SmsExtension::Sms).sms_perform(thing, options)
    end
    
    it "should use values passed into hash if it's provided" do
      thing = double('thing')
      thing.stub(:attributes).and_return({:fake => "fake"})
      options = {:from_phone_number => "1234", :phone_number => "5678", :outgoing_message_format => "hotdog"}
      setup_twilio
      @twilio_account.stub_chain(:sms, :messages, :create).with({:from => "1234", :to => "5678", :body => "hotdog"})
      Class.new.extend(AP::SmsExtension::Sms).sms_perform(thing, options)
    end
    
  end

end
require 'spec_helper'
require 'sms_extension/consume_sms'

describe SmsExtension::ConsumeSms::Consumer do
  
  def setup_twilio
    twilio_client = double('twilio_client')
    Twilio::REST::Client.should_receive(:new).with(any_args()).and_return(twilio_client)
    @twilio_account = double('twilio_account')
    twilio_client.should_receive(:account).and_return(@twilio_account) 
  end
  
  def twilio_owned_numbers
    twilio_owned_number0 = double('twilio_owned_number')
    twilio_owned_number0.stub(:phone_number).and_return("9789445742")
    twilio_owned_number0.stub(:sms_url).and_return("http://localhost/consume")
    twilio_owned_number1 = double('twilio_owned_number')
    twilio_owned_number1.stub(:phone_number).and_return("9789445743")
    twilio_owned_number1.stub(:sms_url).and_return("http://localhost/consume")
    twilio_owned_numbers = [twilio_owned_number0, twilio_owned_number1]
  end
  
  describe "available phone numbers" do 
    before(:each) do
      @account = Factory.build(:account)
      @consumer = ConsumeSms::Consumer.new(@account)
    
      setup_twilio
    end

    it "should know how to find available phone numbers" do
      twilio_owned_number = double('twilio_owned_number')
      twilio_owned_number.stub(:phone_number).and_return("9789445743")
      twilio_owned_number.stub(:sms_url).and_return("")
      twilio_owned_numbers_with_emtpy_sms_url = twilio_owned_numbers << twilio_owned_number
      @twilio_account.stub_chain(:incoming_phone_numbers, :list).and_return(twilio_owned_numbers_with_emtpy_sms_url)
      @consumer.find_available_purchased_phone_number(["9789445741", "9789999999"]).should_not be_nil
    end
  
    it "should know that there's no available phone number" do
      @twilio_account.stub_chain(:incoming_phone_numbers, :list).and_return(twilio_owned_numbers)
      @consumer.find_available_purchased_phone_number(["9789445741", "9789999999"]).should be_nil
    end
  
    it "should know that there's no available phone number" do
      @twilio_account.stub_chain(:incoming_phone_numbers, :list).and_return(twilio_owned_numbers)
      @consumer.find_available_purchased_phone_number(["9789445741", "9789999999"]).should be_nil
    end

  end
end
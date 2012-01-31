require 'spec_helper'
require 'consume_sms/consumer'

describe ConsumeSms::Consumer do
  before(:each) do
    @account = Factory.build(:account)
    @consumer = ConsumeSms::Consumer.new(@account)
  end
  
  def setup_twilio
    twilio_client = double('twilio_client')
    Twilio::REST::Client.should_receive(:new).with(any_args()).and_return(twilio_client)
    @twilio_account = double('twilio_account')
    twilio_client.should_receive(:account).and_return(@twilio_account) 
  end
  
  it "should know how to find available phone numbers" do
    twilio_owned_number0 = double('twilio_owned_number')
    twilio_owned_number0.stub(:phone_number).and_return("9789445742")
    twilio_owned_number1 = double('twilio_owned_number')
    twilio_owned_number1.stub(:phone_number).and_return("9789445743")
    twilio_owned_numbers = [twilio_owned_number0, twilio_owned_number1]

    setup_twilio

    @twilio_account.stub_chain(:incoming_phone_numbers, :list).and_return(twilio_owned_numbers)
    @consumer.find_available_purchased_phone_number(["9789445741", "9789999999"]).should_not be_nil
  end
  
  it "should know that there's no available phone number" do
    twilio_owned_number0 = double('twilio_owned_number')
    twilio_owned_number0.stub(:phone_number).and_return("9789445741")
    twilio_owned_number1 = double('twilio_owned_number')
    twilio_owned_number1.stub(:phone_number).and_return("9789999999")
    twilio_owned_numbers = [twilio_owned_number0, twilio_owned_number1]
    
    setup_twilio
    
    @twilio_account.stub_chain(:incoming_phone_numbers, :list).and_return(twilio_owned_numbers)
    @consumer.find_available_purchased_phone_number(["9789445741", "9789999999"]).should be_nil
  end

  describe "connect to api" do
    it "should raise error when redirecting" do
      response = Net::HTTPRedirection.new(nil, nil, nil)
      ConsumeSms.stub(:connect_to_api).with(any_args()).and_return(response)
      
      message = Message.new
      text_message_options = {"#1" => "cow"}
      message.body = "#1"
      expect {@consumer.consume_sms(message, text_message_options)}.should raise_error(ConsumeSms::GeneralTextMessageNotifierException)
    end
  end
  
end
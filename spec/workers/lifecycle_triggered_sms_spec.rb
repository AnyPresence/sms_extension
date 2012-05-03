require 'spec_helper'

describe LifecycleTriggeredSms do
  describe "limit" do
    def generate_phone_numbers(max)
      @account = Factory.create(:account)
      r = Random.new
      random_number = r.rand(5..max)
      phone_numbers = []
      (1..random_number).each do |n|
        p = double(String)
        p.stub_chain(:strip, :empty?).and_return(true)
        phone_numbers << p
      end
      
      phone_numbers
    end
    
    it "should limit the amount of outgoing texts to the value of MAX_OUTGOING_SMS_PER_LC_EVENT" do
      phone_numbers = generate_phone_numbers(ENV['MAX_OUTGOING_SMS_PER_LC_EVENT'].to_i)
      Account.any_instance.stub(:object_instances).and_return(phone_numbers)
      ConsumeSms::Consumer.stub(:send_sms)
      ConsumeSms::Consumer.should_receive(:send_sms).at_most(ENV['MAX_OUTGOING_SMS_PER_LC_EVENT'].to_i).times
      LifecycleTriggeredSms::perform({'from' => 'some_number', 'body' => 'hello world'}, @account.id, 'customer', '{{customer.phone_number}}')
    end
    
    it "should only send texts to the list of phone numbers found" do
      ENV['MAX_OUTGOING_SMS_PER_LC_EVENT'] = "100"
      phone_numbers = generate_phone_numbers(40)
      Account.any_instance.stub(:object_instances).and_return(phone_numbers)
      #ConsumeSms::Consumer.stub(:send_sms)
      ConsumeSms::Consumer.should_receive(:send_sms).exactly(phone_numbers.size).times
      LifecycleTriggeredSms::perform({'from' => 'some_number', 'body' => 'hello world'}, @account.id, 'customer', '{{customer.phone_number}}')
    end
  end
end
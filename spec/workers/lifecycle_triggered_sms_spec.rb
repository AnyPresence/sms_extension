require 'spec_helper'

describe LifecycleTriggeredSms do
  describe "limit" do
    it "should limit the amount of outgoing texts" do
      @account = Factory.create(:account)
      r = Random.new
      random_number = r.rand(5..20)
      phone_numbers = []
      (1..random_number).each do |n|
        p = double(String)
        p.stub(:strip)
        phone_numbers << p
      end

      Account.any_instance.stub(:object_instances).and_return(phone_numbers)
      ConsumeSms::Consumer.stub(:send_sms)
      ConsumeSms::Consumer.should_receive(:send_sms).at_most(ENV['MAX_OUTGOING_SMS_PER_LC_EVENT'].to_i).times
      LifecycleTriggeredSms::perform({'from' => '9789445741', 'body' => 'hello world'}, @account.id, 'customer', '{{customer.phone_number}}')
    end
  end
end
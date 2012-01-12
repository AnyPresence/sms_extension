require 'spec_helper'
require 'consume_sms/consume'

describe ConsumeSms::Consumer do
  before(:each) do
    account = Factory.build(:account)
    @consumer = ConsumeSms::Consumer.new(account.application_id, account.field_name)
  end 

end
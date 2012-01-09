require 'spec_helper'
require File.dirname(__FILE__)  + '/../../lib/consume_sms/consume'

describe ConsumeSMS do
  include ConsumeSMS
  
  describe "should try this" do
    it "should consume" do
      c = ConsumeSMS::Consumer.new
    
      c.consume_sms("test")
    end
  end
  
end
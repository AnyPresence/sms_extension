class Message < ActiveRecord::Base
  validates_presence_of :from, :to
     
  attr_accessible :sms_message_sid, :account_sid, :body, :from, :to
end

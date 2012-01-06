class Message < ActiveRecord::Base
   attr_accessor :SmsMessageSid, :AccountSid, :Body, :From, :To
end

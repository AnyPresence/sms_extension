class Message < ActiveRecord::Base
   attr_accessor :smsMessageSid, :accountSid, :body, :from, :to
   
   validates_presence_of :from, :to
end

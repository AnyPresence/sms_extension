# This class handles the asynchronouos outgoing SMS to phone numbers.
class LifecycleTriggeredSms
  @queue = :sms
  
  def self.perform(options, account_id, object_name, format)
    account = Account.find(account_id)
    
    # Get objects so that we can extract the phone number.
    phone_numbers = account.object_instances(object_name, format)
    
    phone_numbers = [phone_numbers] unless phone_numbers.kind_of?(Array)
    Rails.logger.info "Phone numberes: " + phone_numbers.inspect
    phone_numbers.each do |o|
      ConsumeSms::Consumer.send_sms({:from => options['from'], :to => o.strip, :body => options['body']})
    end
  end
end
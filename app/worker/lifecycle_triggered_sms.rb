# This class handles the asynchronouos outgoing SMS to phone numbers.
class LifecycleTriggeredSms
  @queue = :sms
  
  def self.perform(options, account_id, object_name, format)
    if ENV['MAX_OUTGOING_SMS_PER_LC_EVENT'].nil?
      raise "Unable to send text. The environment variable MAX_OUTGOING_SMS_PER_LC_EVENT must be set."
    end
    account = Account.find(account_id)
    
    # Get objects so that we can extract the phone number.
    phone_numbers = account.object_instances(object_name, format, {:query => "all"})
    
    phone_numbers = [phone_numbers] unless phone_numbers.kind_of?(Array)
    
    count = 0
    phone_numbers.each do |o|
      if count == ENV['MAX_OUTGOING_SMS_PER_LC_EVENT'].to_i
        return
      end
     
      next if o.strip.empty?
      begin
        Rails.logger.info "Sending text to: #{o.strip} , from: #{options['from']}"
        ConsumeSms::Consumer.send_sms({:from => options['from'], :to => o.strip, :body => options['body']})
        count += 1
      rescue
        Rails.logger.error $!
        Rails.logger.error $!.backtrace.join("\n")
      end
    end
  end
end
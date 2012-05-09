require 'twilio-ruby'

module SmsExtension
  module Sms
    include SmsExtension::Common
  
    # Creates the account.
    def self.config_account(config={})
      if config.empty?
        raise "Nothing to configure!"
      end
      account = SmsExtension::Account.new(config)
      account.save!
      menu_options = config[:menu_options] 
      if !menu_options.nil?
        menu_options.each do |m|
          menu_option = account.menu_options.build(m)
          menu_option.save
        end
      end
    end
    
    class Consumer
      def initialize(account)
        @account = account
      end
    
      def twilio_account
        @twilio_account ||= Twilio::REST::Client.new(ENV['SMS_EXTENSION.TWILIO_ACCOUNT_SID'], ENV['SMS_EXTENSION.TWILIO_AUTH_TOKEN']).account 
      end
    
      # Consumes the message and returns a message to send back to the client.
      def consume_sms(message, text_message_options)
        object_name = text_message_options[message.body.strip] ? text_message_options[message.body.strip][0] : nil
        format = !object_name.nil? ? text_message_options[message.body.strip][1] : ""
        if message.body.strip == "#0" || object_name.nil?
          keys = text_message_options.keys
          info_message = ""
          keys.each do |x|
            info_message << "#{x} for #{text_message_options[x][0]}\n"
          end
      
          return info_message
        end

        @account.object_instances_as_sms(object_name, format)
      end
    
      # Builds text message to send out.
      #  +options+ is a hash that includes: +:from+, caller's phone number; +:to+, twilio phone number the caller sent the text to; and +body+. body of the text
      #  +params+ are attributes for the object
      #  +object_name+ is the object definition name
      def text(options={}, params, object_name)
        outgoing_text_option = @account.outgoing_text_options.where(:name => object_name).first
        # Find the format string from fields that were passed.
        body = outgoing_text_option.build_text(object_name, params)
      
        # Find the phone number to text to
        bulk_text_phone_number = @account.bulk_text_phone_number
        unless bulk_text_phone_number.blank?
          format = @account.bulk_text_phone_number.format
          object_name_with_phone_number = @account.bulk_text_phone_number.name
          options["body"] = body
          Rails.logger.info("Sending sms...: #{body}")
          #Resque.enqueue(LifecycleTriggeredSms, options, @account.id, object_name_with_phone_number, format)
        else
          # TODO: move this to resque as well.
          begin
            twilio_account.sms.messages.create(:from => options[:from], :to => options[:to], :body => body)
          rescue
            Rails.logger.error "Unable to send SMS..."
            Rails.logger.error $!.backtrace.join("\n")
            raise
          end
        end
      end
    
      # Sends text.
      def self.send_sms(options={})
        twilio_account = Twilio::REST::Client.new(ENV['SMS_EXTENSION.TWILIO_ACCOUNT_SID'], ENV['SMS_EXTENSION.TWILIO_AUTH_TOKEN']).account
        
        begin
          twilio_account.sms.messages.create(:from => options[:from], :to => options[:to], :body => options[:body])
        rescue
          Rails.logger.error "Unable to send SMS..."
          Rails.logger.error $!.backtrace.join("\n")
          raise
        end
      end
    end
  
    # General Exception
    class GeneralTextMessageNotifierException < Exception; end
   
  end
end
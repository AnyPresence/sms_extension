require 'twilio-ruby'

module AP
  module SmsExtension
    module Sms
      include ::SmsExtension::Common

      # Creates the account.
      # +config+ configuration properties should contain:
      #          :phone_number, 
      #          :from_phone_number, 
      #          :outgoing_message_format      
      def self.config_account(config={})
        if config.empty?
          raise "Nothing to configure!"
        end
        # Override the twilio account setting if these environment variables are set.
        config[:twilio_account_sid] = ENV['SMS_EXTENSION_TWILIO_ACCOUNT_SID'] unless ENV['SMS_EXTENSION_TWILIO_ACCOUNT_SID'].nil?
        config[:twilio_auth_token] = ENV['SMS_EXTENSION_TWILIO_AUTH_TOKEN'] unless ENV['SMS_EXTENSION_TWILIO_AUTH_TOKEN'].nil?

        account = nil
        if !::SmsExtension::Account.all.blank?
          account = ::SmsExtension::Account.first          
          account.update_attributes(config)
        else
          account = ::SmsExtension::Account.new(config)
          account.save!
        end

        menu_options = config[:menu_options] 
        if !menu_options.nil?
          menu_options.each do |m|
            menu_option = account.menu_options.build(m)
            menu_option.save
          end
        end
      end
  
      # Builds text message to send out.
      #  +object_instance+ is the object instance
      #  +options+ is a hash that includes: +:from+, caller's phone number; +:to+, twilio phone number to send the text to
      def sms_perform(object_instance, options={})
        account = ::SmsExtension::Account.first
        consumer = AP::SmsExtension::Sms::Consumer.new(account)
        options[:to] ||= account.phone_number
        options[:outgoing_message_format] ||= account.outgoing_message_format
        options[:from] ||= (!account.from_phone_number.blank? ? account.from_phone_number : ENV['SMS_EXTENSION_TWILIO_FROM_SMS_NUMBER'])
        if account.outgoing_message_format.blank?
          raise "Please configure the extension first."
        end
        consumer.text(options, object_instance.attributes, object_instance.class.name, account.outgoing_message_format)
      end
  
      class Consumer
        def initialize(account)
          @account = account
        end
  
        def twilio_account
          @twilio_account ||= Twilio::REST::Client.new(@account [:twilio_account_sid],@account [:twilio_auth_token]).account 
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
        #  +options+ is a hash that includes: +:from+, caller's phone number; +:to+, twilio phone number the caller sent the text to
        #  +params+ are attributes for the object
        #  +object_name+ is the object definition name
        def text(options, params, object_name, format="")
          body = ""
          if format.empty?
            outgoing_text_option = @account.outgoing_text_options.where(:name => object_name).first
            # Find the format string from fields that were passed.
            body = outgoing_text_option.build_text(object_name, params)
          else
            body = ::SmsExtension::MenuOption::parse_format_string(format, object_name, params)
          end

          begin
            twilio_account.sms.messages.create(:from => options[:from], :to => options[:to], :body => body)
          rescue
            Rails.logger.error "Unable to send SMS..."
            Rails.logger.error $!.backtrace.join("\n")
            raise
          end
        end
  
        # Sends text.
        def self.send_sms(options={})
          account = ::SmsExtension::Account.first
          twilio_account_sid = nil
          twilio_auth_token = nil
          unless account.blank?
            twilio_account_sid = account.twilio_account_sid
            twilio_auth_token = account.twilio_auth_token
          end
          
          twilio_account_sid ||= ENV['SMS_EXTENSION_TWILIO_ACCOUNT_SID']
          twilio_auth_token ||= ENV['SMS_EXTENSION_TWILIO_AUTH_TOKEN'] 
          
          twilio_account = Twilio::REST::Client.new(twilio_account_sid, twilio_auth_token).account
      
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
end
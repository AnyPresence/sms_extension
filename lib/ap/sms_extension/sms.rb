require 'twilio-ruby'

module AP
  module SmsExtension
    module Sms
      include ::SmsExtension::Common

      # Configures SMS.
      def self.config_account(config={})
        config = HashWithIndifferentAccess.new(config)
        # Override the twilio account setting if these environment variables are set.
        if !ENV['SMS_EXTENSION_TWILIO_ACCOUNT_SID'].blank?
          twilio_account_sid = ENV['SMS_EXTENSION_TWILIO_ACCOUNT_SID']
        else
          twilio_account_sid = ENV['AP_SMS_NOTIFIER_TWILIO_ACCOUNT_SID']
        end
        
        if !ENV['SMS_EXTENSION_TWILIO_AUTH_TOKEN'].blank?
          twilio_auth_token = ENV['SMS_EXTENSION_TWILIO_AUTH_TOKEN']
        else
          twilio_auth_token = ENV['AP_SMS_NOTIFIER_TWILIO_AUTH_TOKEN']
        end
        
        config[:twilio_account_sid] = twilio_account_sid
        config[:twilio_auth_token] = twilio_auth_token

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
      
      def self.json_config
        @@json ||= ActiveSupport::JSON.decode(File.read("#{File.dirname(__FILE__)}/../../../manifest.json"))
      end
  
      # Builds text message to send out.
      #  +object_instance+ is the object instance
      #  +options+ is a hash that includes: +:from+, caller's phone number; +:to+, twilio phone number to send the text to
      def sms_perform(object_instance, options={})
        account = ::SmsExtension::Account.first
        consumer = AP::SmsExtension::Sms::Consumer.new(account)
        options = HashWithIndifferentAccess.new(options)
        options[:phone_number] ||= account.phone_number
        options[:outgoing_message_format] ||= account.outgoing_message_format
        options[:from_phone_number] ||= (!account.from_phone_number.blank? ? account.from_phone_number : ENV['SMS_EXTENSION_TWILIO_FROM_SMS_NUMBER'])

        consumer.text(options, object_instance.attributes, object_instance.class.name, options[:outgoing_message_format])
      end
  
      class Consumer
        def initialize(account)
          @account = account
        end
  
        def twilio_account
          @twilio_account ||= Twilio::REST::Client.new(@account.twilio_account_sid, @account.twilio_auth_token).account 
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
            body = format
          end

          from_phone_number = options[:from_phone_number]
          phone_number = options[:phone_number]

          begin
            twilio_account.sms.messages.create(:from => from_phone_number, :to => phone_number, :body => body)
          rescue
            Rails.logger.error "Unable to send SMS...: #{$!.message}"
            Rails.logger.error $!.backtrace.join("\n")
            raise
          end
          ::SmsExtension::Message.create(:from => from_phone_number, :to => phone_number, :body => body)
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
          
          if twilio_account_sid.blank?
            if !ENV['SMS_EXTENSION_TWILIO_ACCOUNT_SID'].blank?
              twilio_account_sid = ENV['SMS_EXTENSION_TWILIO_ACCOUNT_SID']
            else
              twilio_account_sid = ENV['AP_SMS_NOTIFIER_TWILIO_ACCOUNT_SID']
            end
          end
          
          if twilio_auth_token.blank?
            if !ENV['SMS_EXTENSION_TWILIO_AUTH_TOKEN'].blank?
              twilio_auth_token = ENV['SMS_EXTENSION_TWILIO_AUTH_TOKEN']
            else
              twilio_auth_token = ENV['AP_SMS_NOTIFIER_TWILIO_AUTH_TOKEN']
            end
          end
          
          twilio_account = Twilio::REST::Client.new(twilio_account_sid, twilio_auth_token).account
      
          begin
            twilio_account.sms.messages.create(:from => options[:from_phone_number], :to => options[:phone_number], :body => options[:body])
          rescue
            Rails.logger.error "Unable to send SMS...: #{$!.message}"
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
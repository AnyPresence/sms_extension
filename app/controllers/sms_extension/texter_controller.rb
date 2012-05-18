require 'ap/sms_extension/sms'

module SmsExtension
  class TexterController < ApplicationController

    before_filter :build_consumer, :only => [:settings, :text, :generate_consume_phone_number]

    # Twilio sends a post to this endpoint
    def consume
      message = SmsExtension::Message.new(:sms_message_sid => params[:SmsMessageSid], :account_sid => params[:AccountSid], :body => params[:Body], :from => params[:From], :to => params[:To])
      Rails.logger.info "Received message: " + message.inspect
      if message.save
        incoming_phone_number = SmsExtension::Message::strip_phone_number_prefix(params[:From])
        consume_phone_number = SmsExtension::Message::strip_phone_number_prefix(params[:To])
      
        accounts = SmsExtension::Account.where(:consume_phone_number => consume_phone_number)
    
        begin
          outbound_message = ""
          debugger
          if !accounts.blank?
            begin
              consumer = SmsExtension::Sms::Consumer.new(accounts.first)
              outbound_message = consumer.consume_sms(message, accounts.first.text_message_options)
            rescue
              Rails.logger.error "Not able to consume the text: " 
              outbound_message = "Unable to obtain data at this time. Please try again later."
            end
          else
            outbound_message = "The extension is not configured for your account."
          end

          Rails.logger.info "Sending message to " + message.from + " : " + outbound_message.inspect
          outbound_message = [outbound_message] unless outbound_message.kind_of?(Array)
          outbound_message.each do |o|
            SmsExtension::Sms::Consumer.send_sms({:from => consume_phone_number, :to => message.from, :body => o.to_s})
          end
          render :json => { :success => true }
        rescue
          render :json => { :success => false, :error => $!.message }
        end
      else
        render :json => { :success => false, :error => message.errors }
      end
    end

  protected
    # Builds the +Consumer+ which accesses Twilio.
    def build_consumer
      @consumer = SmsExtension::Sms::Consumer.new(current_account)
    end

  end
end

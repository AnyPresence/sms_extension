require 'ap/sms_extension/sms'
require_dependency "sms_extension/application_controller"

module SmsExtension
  class TexterController < ApplicationController

    before_filter :build_consumer, :only => [:settings, :text, :generate_consume_phone_number]
    
    def index
      @messages = ::SmsExtension::Message.all.page(params[:page])
    end
    
    def sms
      @message = ::SmsExtension::Message.new
    end
    
    def send_sms
      status = false
      begin
        @message = ::SmsExtension::Message.new(params[:message])
        @message.save!
        ::AP::SmsExtension::Sms::Consumer.send_sms({:from_phone_number => @message.from, :phone_number => @message.to, :body => @message.body})
        status = true
      rescue
        error_msg = "Unable to send message: #{$!}"
        Rails.logger.error(error_msg)
        @message.errors[:base] << error_msg
        status = false
      end
      
      respond_to do |format|
        if status
          format.html { redirect_to settings_path }
        else
          format.html { render 'sms' }
        end
      end  
    end

    # Twilio sends a post to this endpoint
    def consume
      message = ::SmsExtension::Message.new(:sms_message_sid => params[:SmsMessageSid], :account_sid => params[:AccountSid], :body => params[:Body], :from => params[:From], :to => params[:To])
      Rails.logger.info "Received message: " + message.inspect
      if message.save
        incoming_phone_number = SmsExtension::Message::strip_phone_number_prefix(params[:From])
        consume_phone_number = SmsExtension::Message::strip_phone_number_prefix(params[:To])
      
        accounts = ::SmsExtension::Account.where(:consume_phone_number => consume_phone_number)
    
        begin
          outbound_message = ""
          if !accounts.blank?
            begin
              consumer = AP::SmsExtension::Sms::Consumer.new(accounts.first)
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
            AP::SmsExtension::Sms::Consumer.send_sms({:from => consume_phone_number, :to => message.from, :body => o.to_s})
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
      @consumer = AP::SmsExtension::Sms::Consumer.new(current_account)
    end

  end
end

module AnypresenceExtension
  module Common
    module Twilio
      # Finds an account by phone number.
      def find_by_consume_phone_number(phone_number)
        Account.find_by_consume_phone_number(phone_number)
      end

      # Gets the first available phone number if any.
      # An available phone number must be a number in Twilio that we are not using and
      # it must not have an SMS_URL associated with it.
      def phone_number_used(twilio_owned_numbers, used_numbers)
        available_phone_number = nil
        twilio_owned_numbers.each do |x|
          if x.voice_url.empty? && !used_numbers.include?(x.phone_number)
            available_phone_number = x.phone_number
            break
          end
        end
        available_phone_number
      end

      def get_used_phone_numbers
        Account.all.map {|x| x.consume_phone_number }
      end

      # Generates secure parameters for provisioning an extension.
      def generate_secure_parameters
        timestamp = Time.now.to_i
        application_id = @account.application_id
        {timestamp: timestamp.to_s, application_id: application_id, anypresence_auth: Digest::SHA1.hexdigest("#{ENV['SHARED_SECRET']}-#{application_id}-#{timestamp}") } 
      end
    end
  end

end
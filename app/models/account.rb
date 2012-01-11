class Account < ActiveRecord::Base
  devise :token_authenticatable, :rememberable, :trackable
  before_save :ensure_authentication_token
  
  validates_presence_of :application_id

  attr_accessible :remember_me, :phone_number, :field_name, :consume_phone_number, :application_id
  
  # Gets the first available phone number if any
  def self.phone_number_used(twilio_owned_numbers, used_numbers)
    available_phone_number = nil
    twilio_owned_numbers.each do |x|
      if !used_numbers.include?(x.phone_number)
        available_phone_number = x.phone_number
        break
      end
    end
    return available_phone_number
  end
end

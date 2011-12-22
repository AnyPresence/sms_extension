class Account < ActiveRecord::Base
  devise :token_authenticatable, :rememberable, :trackable
  before_save :ensure_authentication_token
  
  validates_presence_of :application_id

  attr_accessible :remember_me, :phone_number, :field_name
end

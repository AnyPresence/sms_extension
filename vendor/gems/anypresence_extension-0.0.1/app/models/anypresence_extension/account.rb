require 'devise'

module AnypresenceExtension
  class Account < ActiveRecord::Base

    devise :token_authenticatable, :rememberable, :trackable
    before_save :ensure_authentication_token

    validates :application_id, :presence => true
    validates :api_host, :presence => true

    attr_accessible :remember_me, :application_id, :extension_id, :api_host

  end
end

module SmsExtension
  module Common
  
    # Gets the current account.
    def current_account
      SmsExtension::Account.first
    end

  end
end

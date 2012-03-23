module AnypresenceExtension 
  module Authenticatable
    def self.sign_secret(shared_secret_key, application_id, timestamp)
      anypresence_auth = Digest::SHA1.hexdigest("#{shared_secret_key}-#{application_id}-#{timestamp}")
      {:anypresence_auth => anypresence_auth, :application_id => application_id, :timestamp => timestamp.to_s}
    end
    
    def http_basic_creds(username, password)
      @http_basic_creds = {:username => username, :password => password}
    end
  end
end
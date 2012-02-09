module AnypresenceExtension 
  module Authenticatable
    
    def credentials?
      credentials.values.all?
    end
  end
end
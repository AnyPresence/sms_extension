require 'sms_extension'
require 'rails'

module SmsExtension
  class Engine < ::Rails::Engine
    isolate_namespace SmsExtension
  end
end

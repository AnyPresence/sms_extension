require 'anypresence_extension'
require 'rails'

module AnypresenceExtension
  class Engine < ::Rails::Engine
    isolate_namespace AnypresenceExtension
  end
end

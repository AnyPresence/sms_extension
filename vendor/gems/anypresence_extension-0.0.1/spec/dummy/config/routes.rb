require 'anypresence_extension/lc_routes'
  
Rails.application.routes.draw do
  anypresence_extension_lifecycle_triggered_action "settings#perform"
  
  mount AnypresenceExtension::Engine => "/"
end

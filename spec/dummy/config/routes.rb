Rails.application.routes.draw do

  resources :outages

  mount SmsExtension::Engine => "/sms_extension"
end

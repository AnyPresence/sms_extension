Rails.application.routes.draw do

  mount SmsExtension::Engine => "/sms_extension"
end

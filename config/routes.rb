SmsExtension::Engine.routes.draw do
  match 'consume' => 'texter#consume'
  get 'settings' => 'texter#index'
  match 'send_sms' => 'texter#send_sms'
  get 'sms' => 'texter#sms'
  
  root :to => "texter#index"
end

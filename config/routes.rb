SmsExtension::Engine.routes.draw do
  match 'consume' => 'texter#consume'
  get 'settings' => 'texter#index'
  
  root :to => "texter#index"
end

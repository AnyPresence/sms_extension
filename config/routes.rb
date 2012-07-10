SmsExtension::Engine.routes.draw do
  match 'settings' => 'texter#settings'
  match 'consume' => 'texter#consume'
end

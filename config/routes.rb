SmsExtension::Engine.routes.draw do
  match 'settings' => 'texter#settings'

  root :to => 'texter#unauthorized'

end

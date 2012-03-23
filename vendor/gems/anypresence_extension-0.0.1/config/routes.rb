
AnypresenceExtension::Engine.routes.draw do
  post 'provision' => 'settings#provision'
  post 'deprovision' => 'settings#deprovision'
  post 'publish' => 'settings#publish'
  match 'settings' => 'settings#settings'

  root :to => 'settings#unauthorized'
  
  #devise_for :accounts, {
  #  class_name: 'AnypresenceExtension::Account',
  #  module: :devise
  #}

end

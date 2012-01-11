ChameleonTextMessageNotifier::Application.routes.draw do

  post 'provision' => 'texter#provision'
  post 'deprovision' => 'texter#deprovision'
  match 'settings' => 'texter#settings'
  post 'text' => 'texter#text'
  post 'consume' => 'texter#consume'
  match 'generate_consume_phone_number' => 'texter#generate_consume_phone_number'

  root :to => 'texter#unauthorized'
  
  devise_for :accounts
  devise_for :users
end

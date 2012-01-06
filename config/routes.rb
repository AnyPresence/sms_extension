ChameleonTextMessageNotifier::Application.routes.draw do

  post 'provision' => 'texter#provision'
  post 'deprovision' => 'texter#deprovision'
  match 'settings' => 'texter#settings'
  post 'text' => 'texter#text'
  post 'consume' => 'texter#consume'

  root :to => 'texter#unauthorized'
  
  devise_for :accounts
  devise_for :users
end

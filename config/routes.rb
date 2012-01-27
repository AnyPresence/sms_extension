ChameleonTextMessageNotifier::Application.routes.draw do
  
  post 'provision' => 'texter#provision'
  post 'deprovision' => 'texter#deprovision'
  match 'settings' => 'texter#settings'
  post 'text' => 'texter#text'
  post 'consume' => 'texter#consume'
  post 'publish' => 'texter#publish'
  match 'generate_consume_phone_number' => 'texter#generate_consume_phone_number'

  root :to => 'texter#unauthorized'
  
  devise_for :accounts
  devise_for :users
  
  resources :accounts do
    resources :menu_options
    resources :outgoing_text_options
  end
end

require 'resque'
require 'resque/server'

ChameleonTextMessageNotifier::Application.routes.draw do
  
  post 'provision' => 'texter#provision'
  post 'deprovision' => 'texter#deprovision'
  post 'text' => 'texter#text'
  post 'consume' => 'texter#consume'
  post 'publish' => 'texter#publish'
  match 'generate_consume_phone_number' => 'texter#generate_consume_phone_number'
  match 'settings' => 'texter#settings'
  match 'display_bulk_text' => 'texter#display_bulk_text'
  post 'text_phone_number' => 'texter#text_phone_number'
  match 'text_phone_number' => 'texter#text_phone_number'


  root :to => 'texter#unauthorized'
  
  mount Resque::Server.new, :at => '/resque'
  
  devise_for :accounts
  devise_for :users
  
  resources :accounts do
    resources :bulk_text_phone_numbers, :controller => "menu_options", :type => "BulkTextPhoneNumber"
    resources :outgoing_text_options, :controller => "menu_options", :type => "OutgoingTextOption"
    resources :menu_options, :controller => "menu_options", :type => "MenuOption"
  end
end

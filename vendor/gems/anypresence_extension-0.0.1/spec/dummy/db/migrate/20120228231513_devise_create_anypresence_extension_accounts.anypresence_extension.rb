# This migration comes from anypresence_extension (originally 20120215221851)
class DeviseCreateAnypresenceExtensionAccounts < ActiveRecord::Migration
  def change
    create_table :anypresence_extension_accounts do |t|
      t.string :application_id
      t.string :api_host
      t.string :api_token
      t.string :api_version
      
      t.integer  :sign_in_count, :default => 0
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip
      t.datetime :remember_created_at
        
      t.string :authentication_token

      t.timestamps
    end
      
    add_index :anypresence_extension_accounts, :authentication_token, :unique => true
    add_index :anypresence_extension_accounts, :application_id, :unique => true
  end
end

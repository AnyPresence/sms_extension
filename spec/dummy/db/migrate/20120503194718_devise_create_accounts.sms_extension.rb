# This migration comes from sms_extension (originally 20111222182647)
class DeviseCreateAccounts < ActiveRecord::Migration
  def change
    create_table(:sms_extension_accounts) do |t|
      t.rememberable
      t.trackable
      t.token_authenticatable
      
      t.string :application_id, :phone_number, :field_name
      
      t.timestamps
    end

    add_index :accounts, :authentication_token, :unique => true
    add_index :accounts, :application_id, :unique => true
  end
end

class AddApiTokenStringToAccounts < ActiveRecord::Migration
  def change
    add_column :sms_extension_accounts, :api_token, :string
  end
end

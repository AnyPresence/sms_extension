class AddApiHostToAccounts < ActiveRecord::Migration
  def change
    add_column :sms_extension_accounts, :api_host, :string
  end
end

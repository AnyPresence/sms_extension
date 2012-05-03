class AddApiVersionFieldOnAccounts < ActiveRecord::Migration
  def change
    add_column :sms_extension_accounts, :api_version, :string
  end
end

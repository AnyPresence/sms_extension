class AddExtensionIdFieldOnAccounts < ActiveRecord::Migration
  def change
    add_column :sms_extension_accounts, :extension_id, :string
  end
end

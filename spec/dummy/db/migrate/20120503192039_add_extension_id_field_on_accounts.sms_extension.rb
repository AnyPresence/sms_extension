# This migration comes from sms_extension (originally 20120130044358)
class AddExtensionIdFieldOnAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :extension_id, :string
  end
end

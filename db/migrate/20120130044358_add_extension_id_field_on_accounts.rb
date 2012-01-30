class AddExtensionIdFieldOnAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :extension_id, :string
  end
end

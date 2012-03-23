class AddExtensionIdToAnypresenceExtensionAccounts < ActiveRecord::Migration
  def change
    add_column :anypresence_extension_accounts, :extension_id, :string

  end
end

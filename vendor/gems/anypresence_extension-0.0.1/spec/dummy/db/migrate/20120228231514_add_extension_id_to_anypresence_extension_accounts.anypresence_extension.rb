# This migration comes from anypresence_extension (originally 20120228193108)
class AddExtensionIdToAnypresenceExtensionAccounts < ActiveRecord::Migration
  def change
    add_column :anypresence_extension_accounts, :extension_id, :string

  end
end

class AddApiVersionFieldOnAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :api_version, :string
  end
end

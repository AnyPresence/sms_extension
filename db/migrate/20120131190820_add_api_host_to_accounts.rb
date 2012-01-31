class AddApiHostToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :api_host, :string
  end
end

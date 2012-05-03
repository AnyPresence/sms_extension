# This migration comes from sms_extension (originally 20120124223328)
class AddApiVersionFieldOnAccounts < ActiveRecord::Migration
  def change
    add_column :sms_extension_accounts, :api_version, :string
  end
end

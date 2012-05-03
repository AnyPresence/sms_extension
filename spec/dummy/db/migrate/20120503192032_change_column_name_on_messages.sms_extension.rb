# This migration comes from sms_extension (originally 20120110001112)
class ChangeColumnNameOnMessages < ActiveRecord::Migration
  def change
    rename_column :messages, :Body, :body
    rename_column :messages, :From, :from
    rename_column :messages, :To, :to
  end

end

class AddReferenceToAccountOnOutgoingTextOptions < ActiveRecord::Migration
  def change
    add_column :outgoing_text_options, :account_id, :integer
  end
end

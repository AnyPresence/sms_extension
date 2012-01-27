class CreateOutgoingTextOptions < ActiveRecord::Migration
  def change
    create_table :outgoing_text_options do |t|
      t.string :name
      t.string :format

      t.timestamps
    end
  end
end

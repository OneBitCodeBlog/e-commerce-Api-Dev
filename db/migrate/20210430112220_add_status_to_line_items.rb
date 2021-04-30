class AddStatusToLineItems < ActiveRecord::Migration[6.0]
  def change
    add_column :line_items, :status, :integer
  end
end

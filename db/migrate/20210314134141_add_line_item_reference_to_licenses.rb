class AddLineItemReferenceToLicenses < ActiveRecord::Migration[6.0]
  def change
    add_reference :licenses, :line_item, foreign_key: true
  end
end

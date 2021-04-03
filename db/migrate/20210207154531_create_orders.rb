class CreateOrders < ActiveRecord::Migration[6.0]
  def change
    create_table :orders do |t|
      t.integer :status
      t.decimal :subtotal, precision: 10, scale: 2
      t.decimal :total_amount, precision: 10, scale: 2
      t.integer :payment_type
      t.integer :installments
      t.references :user, null: false, foreign_key: true
      t.references :coupon, null: true, foreign_key: true

      t.timestamps
    end
  end
end

class CreateJunoCharges < ActiveRecord::Migration[6.0]
  def change
    create_table :juno_charges do |t|
      t.string :key
      t.string :code
      t.string :number
      t.decimal :amount, precision: 10, scale: 2
      t.string :status
      t.string :billet_url
      t.references :order, null: false, foreign_key: true

      t.timestamps
    end
  end
end

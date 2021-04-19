class CreateJunoCreditCardPayments < ActiveRecord::Migration[6.0]
  def change
    create_table :juno_credit_card_payments do |t|
      t.string :key
      t.datetime :release_date
      t.string :status
      t.string :reason
      t.references :charge, null: false, foreign_key: { to_table: :juno_charges }

      t.timestamps
    end
  end
end

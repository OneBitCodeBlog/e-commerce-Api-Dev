class CreateLicenses < ActiveRecord::Migration[6.0]
  def change
    create_table :licenses do |t|
      t.string :key
      t.integer :platform
      t.integer :status
      t.references :game, null: false, foreign_key: true

      t.timestamps
    end
  end
end

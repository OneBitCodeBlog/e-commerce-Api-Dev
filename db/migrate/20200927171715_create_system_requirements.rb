class CreateSystemRequirements < ActiveRecord::Migration[6.0]
  def change
    create_table :system_requirements do |t|
      t.string :name
      t.string :operational_system
      t.string :storage
      t.string :processor
      t.string :memory
      t.string :video_board

      t.timestamps
    end
  end
end

class CreateRooms < ActiveRecord::Migration[7.1]
  def change
    create_table :rooms do |t|
      t.string :number
      t.integer :capacity
      t.text :amenities
      t.references :hotel, null: false, foreign_key: true

      t.timestamps
    end
  end
end

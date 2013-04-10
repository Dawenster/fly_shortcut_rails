class CreateItineraries < ActiveRecord::Migration
  def change
    create_table :itineraries do |t|
      t.datetime :date
      t.integer :origin_airport_id
      t.integer :destination_airport_id
      t.integer :original_price

      t.timestamps
    end
  end
end

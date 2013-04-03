class CreateFlights < ActiveRecord::Migration
  def change
    create_table :flights do |t|
      t.integer :itinerary_id
      t.integer :departure_airport_id
      t.integer :arrival_airport_id
      t.datetime :departure_time
      t.datetime :arrival_time
      t.string :airline
      t.string :flight_no

      t.timestamps
    end
  end
end

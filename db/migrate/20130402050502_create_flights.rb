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
      t.integer :price
      t.integer :number_of_stops
      t.boolean :is_first_flight
      t.integer :second_flight_destination
      t.integer :original_price

      t.timestamps
    end
  end
end

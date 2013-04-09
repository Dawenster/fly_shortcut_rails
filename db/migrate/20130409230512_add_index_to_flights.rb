class AddIndexToFlights < ActiveRecord::Migration
  def change
    add_index :flights, :departure_airport_id
    add_index :flights, :arrival_airport_id
    add_index :flights, :itinerary_id
  end
end

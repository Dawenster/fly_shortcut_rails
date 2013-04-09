class AddIndexToItineraries < ActiveRecord::Migration
  def change
    add_index :itineraries, :origin_airport_id
    add_index :itineraries, :destination_airport_id
  end
end

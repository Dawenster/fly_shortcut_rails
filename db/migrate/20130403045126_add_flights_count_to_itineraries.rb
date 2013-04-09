class AddFlightsCountToItineraries < ActiveRecord::Migration
  def change
    add_column :itineraries, :flights_count, :integer
  end
end

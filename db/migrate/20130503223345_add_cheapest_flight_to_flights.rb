class AddCheapestFlightToFlights < ActiveRecord::Migration
  def change
    add_column :flights, :cheapest_price, :integer
  end
end

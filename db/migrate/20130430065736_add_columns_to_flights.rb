class AddColumnsToFlights < ActiveRecord::Migration
  def change
    add_column :flights, :second_flight_destination, :integer
    add_column :flights, :second_flight_no, :integer
    add_column :flights, :original_price, :integer
  end
end

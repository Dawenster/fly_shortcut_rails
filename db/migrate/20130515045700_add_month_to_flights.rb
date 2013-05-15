class AddMonthToFlights < ActiveRecord::Migration
  def change
    add_column :flights, :month, :string
  end
end

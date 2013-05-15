class AddEpicToFlights < ActiveRecord::Migration
  def change
    add_column :flights, :epic, :boolean
  end
end

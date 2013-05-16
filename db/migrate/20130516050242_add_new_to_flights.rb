class AddNewToFlights < ActiveRecord::Migration
  def change
    add_column :flights, :new, :boolean
  end
end

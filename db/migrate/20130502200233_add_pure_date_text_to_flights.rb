class AddPureDateTextToFlights < ActiveRecord::Migration
  def change
    add_column :flights, :pure_date, :string
  end
end

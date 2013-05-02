class AddShortcutToFlights < ActiveRecord::Migration
  def change
    add_column :flights, :origin_code, :string
    add_column :flights, :shortcut, :boolean
  end
end

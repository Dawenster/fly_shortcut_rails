class DropAirports < ActiveRecord::Migration
  def change
    drop_table :airports
  end
end

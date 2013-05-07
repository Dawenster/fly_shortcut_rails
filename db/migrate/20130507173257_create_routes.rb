class CreateRoutes < ActiveRecord::Migration
  def change
    create_table :routes do |t|
      t.integer :origin_airport_id
      t.integer :destination_airport_id
      t.integer :cheapest_price
      t.string :date

      t.timestamps
    end
  end
end

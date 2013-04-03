class CreateAirports < ActiveRecord::Migration
  def change
    create_table :airports do |t|
      t.string :code
      t.string :name
      t.string :latitude
      t.string :longitude
      t.string :timezone

      t.timestamps
    end
  end
end

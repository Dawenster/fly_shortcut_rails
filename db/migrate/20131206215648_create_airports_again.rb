class CreateAirportsAgain < ActiveRecord::Migration
  def change
    create_table :airports do |t|
      t.string :city
      t.string :name
      t.string :code
      t.float :latitude
      t.float :longitude
      t.string :timezone

      t.timestamps
    end
  end
end

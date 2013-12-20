class CreateAirportsUsers < ActiveRecord::Migration
  def change
    create_table :airports_users do |t|
      t.belongs_to :airport
      t.belongs_to :user
    end
  end
end

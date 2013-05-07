class Route < ActiveRecord::Base
  attr_accessible :origin_airport_id, :destination_airport_id, :cheapest_price, :date
end

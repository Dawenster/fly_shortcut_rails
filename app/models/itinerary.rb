class Itinerary < ActiveRecord::Base
  attr_accessible :date, :destination_airport_id, :origin_airport_id, :original_price, :price

  has_many 		:flights

	belongs_to 	:airport,
							:class_name => Airport,
							:foreign_key => 'origin_airport_id'

	belongs_to 	:airport,
							:class_name => Airport,
							:foreign_key => 'destination_airport_id'

  def first_flight
    flights.order(:departure_time).first
  end

  def self.same
    where('flights_count = 1')
  end

  def self.with_connections
    where('flights_count > 1')
  end
end

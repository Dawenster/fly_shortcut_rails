class Flight < ActiveRecord::Base
  attr_accessible :airline, :arrival_airport_id, :arrival_time, :departure_airport_id, :departure_time, :flight_no, :itinerary_id

  belongs_to 	:itinerary,
  						:counter_cache => true

	belongs_to 	:departure_airport,
							:class_name => Airport,
							:foreign_key => 'departure_airport_id'

	belongs_to 	:arrival_airport,
							:class_name => Airport,
							:foreign_key => 'arrival_airport_id'

  class << self
    def similar_to(flight)
      where(flight_no: flight.flight_no, departure_time: flight.departure_time,
            departure_airport_id: flight.departure_airport_id, arrival_airport_id: flight.arrival_airport_id)
    end
  end
end

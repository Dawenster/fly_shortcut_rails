class Flight < ActiveRecord::Base
  attr_accessible :airline, :arrival_airport_id, :arrival_time, :departure_airport_id, :departure_time, :flight_no, :itinerary_id

  belongs_to 	:itinerary,
  						:counter_cache => true

	belongs_to 	:airport,
							:class_name => Airport,
							:foreign_key => 'departure_airport_id'

	belongs_to 	:airport,
							:class_name => Airport,
							:foreign_key => 'arrival_airport_id'

  def self.similar_to(flight)
    where(flight_no: flight.flight_no, departure_time: flight.departure_time)
  end

  def self.get_shortcuts
    shortcuts = []
    Itinerary.with_connections.each do |itinerary|
      similar_flights = Flight.similar_to(itinerary.first_flight)
      similar_flights.each do |flight|
        if flight.itinerary.price > itinerary.price
          itinerary.update_attributes(:original_price => flight.itinerary.price)
          shortcuts << itinerary.first_flight
        end
      end
    end
    shortcuts
  end
end

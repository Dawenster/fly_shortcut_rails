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
    where(flight_no: flight.flight_no, departure_time: flight.departure_time,
          departure_airport_id: flight.departure_airport_id, arrival_airport_id: flight.arrival_airport_id)
  end

  def self.get_shortcuts
    shortcuts = []
    Itinerary.with_connections.each do |itinerary|
      begin
        non_stop = []
        one_stops = []

        Flight.similar_to(itinerary.first_flight).each do |flight|
          if flight.itinerary.flights_count == 2
            one_stops << flight.itinerary
          else
            non_stop << flight.itinerary
          end
        end
        cheapest_one_stop = one_stops.map { |itinerary| itinerary.price }.sort.shift
        cheapest_itinerary = one_stops.select { |itinerary| itinerary.price == cheapest_one_stop }.first
        if non_stop[0].price > cheapest_one_stop
          cheapest_itinerary.update_attribute(:original_price, non_stop[0].price)
          shortcuts << cheapest_itinerary.first_flight
        end
      rescue
      end
    end
    shortcuts
  end
end

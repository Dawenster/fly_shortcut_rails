class Itinerary < ActiveRecord::Base
  attr_accessible :date, :destination_airport_id, :origin_airport_id, :original_price, :price

  has_many 		:flights

	belongs_to 	:origin_airport,
							:class_name => Airport,
							:foreign_key => 'origin_airport_id'

	belongs_to 	:destination_airport,
							:class_name => Airport,
							:foreign_key => 'destination_airport_id'

  def first_flight
    flights.order(:departure_time).first
  end

  class << self

    def with_connections
      where('flights_count > 1')
    end

    def get_shortcuts
      shortcuts = []
      with_connections.each do |itinerary|
        itinerary.add_shortcuts(shortcuts)
      end
      shortcuts
    end

  end

  def add_shortcuts(shortcuts)
    begin
      non_stop = []
      one_stops = []

      Flight.similar_to(self.first_flight).each do |flight|
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
end

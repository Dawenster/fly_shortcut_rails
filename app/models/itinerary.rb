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
    similar_flights = self.first_flight.similar_flights

    # this array is the first flight of its itinerary
    # it may be on its own or with another flight
    # find the cheapest one in the group
    # if its non-stop then no shortcut (return)
    # keep the shortcut flight and the nonstop in the group

    # level 3
    cheapest_flight = similar_flights.order('price asc').first
    return if cheapest_flight.non_stop?
    non_stop_flight = similar_flights.non_stops.first

    if non_stop_flight
      shortcuts << [cheapest_flight, non_stop_flight]    
    end
  end
end

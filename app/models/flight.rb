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

  def similar_flights
    # level 2
    Flight.where(flight_no: flight_no, departure_time: departure_time,
      departure_airport_id: departure_airport_id, arrival_airport_id: arrival_airport_id)
  end

  def self.similar_flights
    select('flights.id AS original_flight_id,
      departure_airports.name AS departure_airport_name,
      departure_airports.code AS departure_airport_code,
      arrival_airports.name AS arrival_airport_name,
      arrival_airports.code AS arrival_airport_code,
      similar_flights.*').
    joins('INNER JOIN flights AS similar_flights ON
      flights.flight_no             = similar_flights.flight_no AND
      flights.departure_time        = similar_flights.departure_time AND
      flights.departure_airport_id  = similar_flights.departure_airport_id').
    where('flights.is_first_flight = \'t\' AND flights.number_of_stops > 0').
    joins('INNER JOIN airports AS departure_airports ON
      flights.departure_airport_id = departure_airports.id').
    joins('INNER JOIN airports AS arrival_airports ON
      flights.arrival_airport_id = arrival_airports.id').
    order('original_flight_id asc, similar_flights.price asc').all.group_by { |f| f.original_flight_id }
  end

  def self.non_stops
    where(number_of_stops: 0)
  end

  def non_stop?
    number_of_stops == 0
  end

  def rounded_price
    price / 100 + 1
  end

  def self.with_connections
    where('number_of_stops > 0')
  end

  def self.first_flights
    where(is_first_flight: true)
  end

  def self.get_shortcuts
    shortcuts = []
    similar_flights.each do |original_flight_id, similar_flights|
      add_shortcuts(shortcuts, similar_flights)
    end
    shortcuts
  end

  def self.add_shortcuts(shortcuts, similar_flights)

    cheapest_flight = similar_flights.first
    return if cheapest_flight.non_stop?
    non_stop_flight = similar_flights.find {|f| f.number_of_stops == 0 }

    if non_stop_flight
      shortcuts << [cheapest_flight, non_stop_flight]    
    end

    # this array is the first flight of its itinerary
    # it may be on its own or with another flight
    # find the cheapest one in the group
    # if its non-stop then no shortcut (return)
    # keep the shortcut flight and the nonstop in the group

    # level 3

  end

end

class FlightsController < ApplicationController
  def home
  	shortcuts = get_shortcuts.uniq
		@flights = []

		shortcuts.each do |shortcut|
			shortcut.flights.each do |flight|
				if flight.departure_airport_id == shortcut.origin_airport_id
					@flights << flight
				end
			end	
		end
  end

  def about_us
  end

  def get_shortcuts
		shortcuts = []
		all_itineraries = Itinerary.all
		all_itineraries.each do |itinerary|
			
			if itinerary.flights.count > 1
				first_flight = ""
				if itinerary.flights[0].departure_time > itinerary.flights[1].departure_time
					first_flight = itinerary.flights[1]
				else
					first_flight = itinerary.flights[0]
				end

				sim_flights = Flight.where('flight_no = ? AND
																		departure_time = ?',
																		first_flight.flight_no,
																		first_flight.departure_time)

				sim_flights.each do |flight|
					if flight.itinerary.price > itinerary.price
						itinerary.update_attributes(:original_price => flight.itinerary.price)
						shortcuts << itinerary
						puts shortcuts
					end
				end
			end
		end
		shortcuts
	end
end

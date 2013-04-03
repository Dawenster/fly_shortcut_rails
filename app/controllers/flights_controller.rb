class FlightsController < ApplicationController
  def index
    # @flights = Flight.get_all_shortcuts
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

  def get_shortcuts
    shortcuts = []
    Itinerary.with_connections.each do |itinerary|
      # itinerary.find_shortcuts
      
    # all itineraries with connecting flights
      similar_flights = Flight.similar_to(itinerary.first_flight)

      similar_flights.each do |flight|
        if flight.itinerary.price > itinerary.price
          itinerary.update_attributes(:original_price => flight.itinerary.price)
          shortcuts << itinerary
        end
      end
    end
    shortcuts
  end
end

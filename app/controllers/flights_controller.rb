class FlightsController < ApplicationController
  def index
    @flights = Flight.get_shortcuts.uniq
    @from = []
    @to = []
    @dates = []

    @flights.each do |flight|
      @from << flight[0].departure_airport.name
      @to << flight[0].arrival_airport.name
      @dates << flight[0].departure_time.strftime('%Y-%m-%d')
    end
    @from = @from.uniq.sort
    @to = @to.uniq.sort
    @dates = @dates.uniq.sort
  end
end

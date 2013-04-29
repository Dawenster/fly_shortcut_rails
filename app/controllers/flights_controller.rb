class FlightsController < ApplicationController
  def index
    @flights = Flight.get_shortcuts.uniq
    @from = []
    @to = []
    @dates = []

    @flights.sort_by! { |flight| flight[0].price }
    @flights.uniq! { |flight| flight[0].flight_no + flight[0].airline }

    @flights.each do |flight|
      @from << flight[0].departure_airport.name
      @to << flight[0].arrival_airport.name
      @dates << flight[0].departure_time.strftime('%Y-%m-%d')
    end
    @from = @from.uniq.sort.unshift("Any")
    @to = @to.uniq.sort.unshift("Any")
    @dates = @dates.uniq.sort.unshift("Any")
  end
end

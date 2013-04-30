class FlightsController < ApplicationController
  def index
    # @flights = Flight.get_shortcuts.uniq
    @flights = Flight.all
    @from = []
    @to = []
    @dates = []
    @readable_dates = []
    @combinations = []

    @flights.sort_by! { |flight| flight.price }
    @flights.uniq! { |flight| flight.flight_no + flight.airline }

    @flights.each do |flight|
      depart = flight.departure_airport.name
      arrive = flight.arrival_airport.name
      date = flight.departure_time.strftime('%Y-%m-%d')
      readable_date = flight.departure_time.strftime('%B %d, %Y')
      @from << depart
      @to << arrive
      @dates << date
      @readable_dates << readable_date
      @combinations << [depart, arrive, date, readable_date]
    end

    @from = @from.uniq.sort.unshift("Any")
    @to = @to.uniq.sort.unshift("Any")
    @dates = @dates.uniq.sort.unshift("Any")
    @readable_dates = @readable_dates.uniq.sort.unshift("Any")

    respond_to do |format|
      format.html  # index.html.erb
      format.json  { render :json => { combinations: @combinations, from: @from, to: @to, dates: @dates, readable_dates: @readable_dates } }
    end
  end
end

class FlightsController < ApplicationController
  def index
    @flights = Flight.get_shortcuts.uniq
    @from = []
    @to = []
    @dates = []
    @combinations = []

    @flights.sort_by! { |flight| flight[0].price }
    @flights.uniq! { |flight| flight[0].flight_no + flight[0].airline }

    @flights.each do |flight|
      depart = flight[0].departure_airport.name
      arrive = flight[0].arrival_airport.name
      date = flight[0].departure_time.strftime('%Y-%m-%d')
      @from << depart
      @to << arrive
      @dates << date
      @combinations << [depart, arrive, date]
    end

    @from = @from.uniq.sort.unshift("Any")
    @to = @to.uniq.sort.unshift("Any")
    @dates = @dates.uniq.sort.unshift("Any")

    respond_to do |format|
      format.html  # index.html.erb
      format.json  { render :json => @combinations }
    end
  end
end

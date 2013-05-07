class FlightsController < ApplicationController
  def index
    @flights = Flight.where(:shortcut => true)
    @from = []
    @to = []
    @combinations = []
    month1 = Time.now.strftime('%B')
    month2 = (Time.now + 1.month).strftime('%B')
    month3 = (Time.now + 2.months).strftime('%B')
    @months = [month1, month2, month3]

    @flights.sort_by! { |flight| flight.price }
    @flights.uniq! { |flight| flight.flight_no + flight.airline }

    @flights.each do |flight|
      depart = flight.departure_airport.name
      arrive = flight.arrival_airport.name
      @from << depart
      @to << arrive
      @combinations << [depart, arrive]
    end

    @from = @from.uniq.sort.unshift("Any")
    @to = @to.uniq.sort.unshift("Any")

    respond_to do |format|
      format.html  # index.html.erb
      format.json  { render :json => { combinations: @combinations, from: @from, to: @to } }
    end
  end
end

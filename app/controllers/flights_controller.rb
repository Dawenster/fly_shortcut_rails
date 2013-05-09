class FlightsController < ApplicationController
  def index
    all_shortcuts = Flight.where("shortcut = ? AND cheapest_price > ?", true, 0)
    @flights = all_shortcuts.select{ |flight| flight.epic? }
    @from = []
    @to = []
    @combinations = []
    month1 = Time.now.strftime('%B')
    month2 = (Time.now + 1.month).strftime('%B')
    month3 = (Time.now + 2.months).strftime('%B')
    @months = [month1, month2, month3]

    @flights.sort_by! { |flight| flight.price }
    @flights.uniq! { |flight| flight.flight_no + flight.airline }

    all_shortcuts.each do |flight|
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
      format.json { render :json => { combinations: @combinations, from: @from, to: @to } }
    end
  end

  def filter
    @flights = []
    Flight.where(:shortcut => true).each do |flight|
      # binding.pry
      if params[:type] == "Epic"
        @flights << flight if flight.epic? &&
        (flight.departure_airport.name == params[:from] || params[:from] == "Any") &&
        (flight.arrival_airport.name == params[:to] || params[:to] == "Any") &&
        (params[:month1] && flight.departure_time.strftime('%B') == params[:month1] ||
        params[:month2] && flight.departure_time.strftime('%B') == params[:month2] ||
        params[:month3] && flight.departure_time.strftime('%B') == params[:month3])
      else
        (flight.departure_airport.name == params[:from] || params[:from] == "Any") &&
        (flight.arrival_airport.name == params[:to] || params[:to] == "Any") &&
        @flights << flight if (params[:month1] && flight.departure_time.strftime('%B') == params[:month1] ||
        params[:month2] && flight.departure_time.strftime('%B') == params[:month2] ||
        params[:month3] && flight.departure_time.strftime('%B') == params[:month3])
      end
    end
    if params[:sort] == "Price"
      @flights.sort_by! { |flight| flight.price }
    else
      @flights.sort_by! { |flight| flight.departure_time }
    end
    @flights.uniq! { |flight| flight.flight_no + flight.airline }
    respond_to do |format|
      format.json { render :json => { :partial => render_to_string('_flights.html.erb') } }
    end
  end
end

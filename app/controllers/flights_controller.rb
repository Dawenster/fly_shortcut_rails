require 'will_paginate/array'

class FlightsController < ApplicationController
  def index
    @flights = Flight.where("shortcut = ? AND cheapest_price > ? AND epic = ?", true, 0, true).order("price ASC").paginate(:page => 1, :per_page => 10)
    @from, @to, @combinations = [], [], []
    @user = User.new

    all_shortcuts = Flight.find(:all, :conditions => ["shortcut = ? AND cheapest_price > ?", true, 0], :select => "departure_airport_id, arrival_airport_id", :group => "departure_airport_id, arrival_airport_id")

    all_shortcuts.each do |flight|
      depart = flight.departure_airport.name if flight.departure_airport
      arrive = flight.arrival_airport.name if flight.arrival_airport
      @from << depart if depart
      @to << arrive if arrive
      @combinations << [depart, arrive] if depart
    end

    @airports = Airport.all.map { |airport| airport.name }.unshift("(Desired departure airport)")

    @empty_search = false

    @from = @from.uniq.sort.unshift("Any")
    @to = @to.uniq.sort.unshift("Any")
    @combinations = @combinations.uniq

    respond_to do |format|
      format.html
      format.json { render :json => { :combinations => @combinations, :from => @from, :to => @to } }
    end
  end

  def filter
    params[:sort] == "Price" ? sort = "price ASC" : sort = "departure_time ASC"

    if params[:from] == "Any"
      from_where = "departure_airport_id > ?"
      from = 0
    else
      from_where = "departure_airport_id = ?"
      from = Airport.find_by_name(params[:from]).id
    end

    if params[:to] == "Any"
      to_where = "arrival_airport_id > ?"
      to = 0
    else
      to_where = "arrival_airport_id = ?"
      to = Airport.find_by_name(params[:to]).id
    end

    if params[:dates] == ""
      start_date = Time.now - 1.year
      end_date = Time.now + 1.year
    else
      dates = params[:dates].split(" - ") 
      start_date = DateTime.strptime(dates[0], "%B %d, %Y")
      end_date = DateTime.strptime(dates[1], "%B %d, %Y") + 1.day
    end

    if params[:type] == "Epic"
      @flights = Flight.where("shortcut = ? AND cheapest_price > ? AND #{from_where} AND #{to_where} AND departure_time >= ? AND arrival_time <= ? AND epic = ?", true, 0, from, to, start_date, end_date, true).order(sort).paginate(:page => params[:page], :per_page => 10)
    else
      @flights = Flight.where("shortcut = ? AND cheapest_price > ? AND #{from_where} AND #{to_where} AND departure_time >= ? AND arrival_time <= ?", true, 0, from, to, start_date, end_date).order(sort).paginate(:page => params[:page], :per_page => 10)
    end

    @user = User.new

    @empty_search = false
    @empty_search = true if @flights.empty? && !params[:scroll]
    
    respond_to do |format|
      if @flights.any?
        format.json { render :json => { :flights => render_to_string('_flights.html.erb') } }
      elsif @empty_search
        format.json { render :json => { :flights => render_to_string('_flights.html.erb'), :noMoreFlights => true } }
      else
        format.json { render :json => { :flights => "<div class='no-more-flights label label-info'>No more flights to show</div>", :noMoreFlights => true } }
      end
    end
  end
end

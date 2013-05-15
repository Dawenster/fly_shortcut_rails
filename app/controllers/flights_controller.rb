require 'will_paginate/array'

class FlightsController < ApplicationController
  def index
    @flights = Flight.where("shortcut = ? AND cheapest_price > ? AND epic = ?", true, 0, true).order("price ASC").paginate(:page => 1, :per_page => 10)
    @from, @to, @combinations = [], [], []
    @user = User.new

    @month1 = Time.now.strftime('%B')
    @month2 = (Time.now + 1.month).strftime('%B')
    @month3 = (Time.now + 2.months).strftime('%B')

    all_shortcuts = Flight.find(:all, :conditions => "shortcut = true", :select => "departure_airport_id, arrival_airport_id", :group => "departure_airport_id, arrival_airport_id")

    all_shortcuts.each do |flight|
      depart = flight.departure_airport.name
      arrive = flight.arrival_airport.name
      @from << depart
      @to << arrive
      @combinations << [depart, arrive]
    end

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
    months = []

    params[:sort] == "Price" ? sort = "price ASC" : sort = "departure_time ASC"

    months << params[:month1] if params[:month1]
    months << params[:month2] if params[:month2]
    months << params[:month3] if params[:month3]
    months << nil if months.empty?

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

    if params[:type] == "Epic"
      case months.count
      when 3
        month_where = "AND (month = ? OR month = ? OR month = ?)"
        @flights = Flight.where("shortcut = ? AND cheapest_price > ? AND #{from_where} AND #{to_where} AND epic = ? #{month_where}", true, 0, from, to, true, months[0], months[1], months[2]).order(sort).paginate(:page => params[:page], :per_page => 10)
      when 2
        month_where = "AND (month = ? OR month = ?)"
        @flights = Flight.where("shortcut = ? AND cheapest_price > ? AND #{from_where} AND #{to_where} AND epic = ? #{month_where}", true, 0, from, to, true, months[0], months[1]).order(sort).paginate(:page => params[:page], :per_page => 10)
      when 1
        month_where = "AND month = ?"
        @flights = Flight.where("shortcut = ? AND cheapest_price > ? AND #{from_where} AND #{to_where} AND epic = ? #{month_where}", true, 0, from, to, true, months[0]).order(sort).paginate(:page => params[:page], :per_page => 10)
      else
        month_where = "AND month != ?"
        @flights = Flight.where("shortcut = ? AND cheapest_price > ? AND #{from_where} AND #{to_where} AND epic = ? #{month_where}", true, 0, from, to, true, months[0]).order(sort).paginate(:page => params[:page], :per_page => 10)
      end
    else
      case months.count
      when 3
        month_where = "AND (month = ? OR month = ? OR month = ?)"
        @flights = Flight.where("shortcut = ? AND cheapest_price > ? AND #{from_where} AND #{to_where} #{month_where}", true, 0, from, to, months[0], months[1], months[2]).order(sort).paginate(:page => params[:page], :per_page => 10)
      when 2
        month_where = "AND (month = ? OR month = ?)"
        @flights = Flight.where("shortcut = ? AND cheapest_price > ? AND #{from_where} AND #{to_where} #{month_where}", true, 0, from, to, months[0], months[1]).order(sort).paginate(:page => params[:page], :per_page => 10)
      when 1
        month_where = "AND month = ?"
        @flights = Flight.where("shortcut = ? AND cheapest_price > ? AND #{from_where} AND #{to_where} #{month_where}", true, 0, from, to, months[0]).order(sort).paginate(:page => params[:page], :per_page => 10)
      else
        month_where = "AND month != ?"
        @flights = Flight.where("shortcut = ? AND cheapest_price > ? AND #{from_where} AND #{to_where} #{month_where}", true, 0, from, to, months[0]).order(sort).paginate(:page => params[:page], :per_page => 10)
      end
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

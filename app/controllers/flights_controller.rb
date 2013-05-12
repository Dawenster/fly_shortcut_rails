require 'will_paginate/array'

class FlightsController < ApplicationController
  def index
    all_shortcuts = Flight.where("shortcut = ? AND cheapest_price > ?", true, 0)
    @flights, @from, @to, @combinations = [], [], [], []
    @epic, @all, @total_saved = 0, 0, 0
    @stats = {}
    @user = User.new

    month1 = Time.now.strftime('%B')
    month2 = (Time.now + 1.month).strftime('%B')
    month3 = (Time.now + 2.months).strftime('%B')
    @months = [month1, month2, month3]

    all_shortcuts.each do |flight|
      @flights << flight if flight.epic?
      @stats["#{flight.departure_airport.code} - #{flight.arrival_airport.code}"] ||= [0, 0, 0]
      @stats["#{flight.departure_airport.code} - #{flight.arrival_airport.code}"][1] += 1
      @stats["#{flight.departure_airport.code} - #{flight.arrival_airport.code}"][2] += (flight.original_price - flight.price)
      if flight.epic?
        @stats["#{flight.departure_airport.code} - #{flight.arrival_airport.code}"][0] += 1
      end
    end

    @stats.values.each do |stat|
      @epic += stat[0]
      @all += stat[1]
      @total_saved += stat[2]
    end

    @total_saved /= 100

    @flights.sort_by! { |flight| flight.price }
    @flights = @flights.paginate(:page => 1, :per_page => 10)

    @empty_search = false

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
      format.json { render :json => { :combinations => @combinations.uniq!, :from => @from, :to => @to } }
    end
  end

  def filter
    @flights, @routes = [], []
    @epic, @all, @total_saved = 0, 0, 0
    @user = User.new
    @stats = {}

    all_shortcuts = Flight.where("shortcut = ? AND cheapest_price > ?", true, 0)

    all_shortcuts.each do |flight|
      if params[:type] == "Epic"
        @flights << flight if flight.epic? &&
        (flight.departure_airport.name == params[:from] || params[:from] == "Any") &&
        (flight.arrival_airport.name == params[:to] || params[:to] == "Any") &&
        (flight.departure_time.strftime('%B') == params[:month1] ||
        flight.departure_time.strftime('%B') == params[:month2] ||
        flight.departure_time.strftime('%B') == params[:month3])
      else
        @flights << flight if (flight.departure_airport.name == params[:from] || params[:from] == "Any") &&
        (flight.arrival_airport.name == params[:to] || params[:to] == "Any") &&
        (flight.departure_time.strftime('%B') == params[:month1] ||
        flight.departure_time.strftime('%B') == params[:month2] ||
        flight.departure_time.strftime('%B') == params[:month3])
      end
    end

    unless params[:scroll]
      all_shortcuts.each do |flight|
        if (flight.departure_airport.name == params[:from] || params[:from] == "Any") &&
          (flight.arrival_airport.name == params[:to] || params[:to] == "Any") &&
          (params[:month1] && flight.departure_time.strftime('%B') == params[:month1] ||
          params[:month2] && flight.departure_time.strftime('%B') == params[:month2] ||
          params[:month3] && flight.departure_time.strftime('%B') == params[:month3])
            @stats["#{flight.departure_airport.code} - #{flight.arrival_airport.code}"] ||= [0, 0, 0]
            @stats["#{flight.departure_airport.code} - #{flight.arrival_airport.code}"][1] += 1
            @stats["#{flight.departure_airport.code} - #{flight.arrival_airport.code}"][2] += (flight.original_price - flight.price)
            if flight.epic?
              @stats["#{flight.departure_airport.code} - #{flight.arrival_airport.code}"][0] += 1
            end
        end
      end
      @stats.values.each do |stat|
        @epic += stat[0]
        @all += stat[1]
        @total_saved += stat[2]
      end

      @total_saved /= 100
      
      if params[:sort] == "Price"
        @flights.sort_by! { |flight| flight.price }
      else
        @flights.sort_by! { |flight| flight.departure_time }
      end
      @empty_search = false
      @empty_search = true if @flights.empty?
    end

    @flights = @flights.paginate(:page => params[:page], :per_page => 10)
    
    respond_to do |format|
      if @flights.any?
        format.json { render :json => { :flights => render_to_string('_flights.html.erb'), :stats => render_to_string('layouts/_flight_stats.html.erb') } }
      elsif @empty_search
        format.json { render :json => { :flights => render_to_string('_flights.html.erb'), :stats => render_to_string('layouts/_flight_stats.html.erb'), :noMoreFlights => true } }
      else
        format.json { render :json => { :flights => "<div class='no-more-flights label label-info'>No more flights to show</div>", :noMoreFlights => true } }
      end
    end
  end
end

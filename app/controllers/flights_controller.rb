require 'will_paginate/array'

class FlightsController < ApplicationController
  def index
    # Geomatch index
    geomatch_city = {
      "Los Angeles" => "LAX"
    }

    geomatch_region = {
      "Alberta" => "YYC",
      "Illinois" => "ORD",
      "New York" => "JFK",
      "California" => "SFO",
      "Ontario" => "YYZ",
      "British Columbia" => "YVR"
    }

    # Seeing if there's a geocode match
    request_data = request.location.data
    # request_data = Geocoder.search("74.212.154.18")[0].data # Test for Los Angeles
    # request_data = Geocoder.search("99.140.218.14")[0].data # Test for Illinois
    origin_code = geomatch_city[request_data["city"]]
    origin_code ||= geomatch_region[request_data["region_name"]]

    # Else set the default
    origin_code ||= "SFO"
    origin_airport = Airport.find_by_code(origin_code)

    @user = User.new
    @airports = Airport.all.map { |airport| airport.name }.unshift("(Desired departure airport)")
    @empty_search = false

    params_to_send = {
      :password => ENV['POST_PASSWORD']
    }

    results = JSON.parse(RestClient.get "http://fs-#{origin_code.downcase}-api.herokuapp.com/flights", { :params => params_to_send })
    @flights = results["flights"]

    @from = [
      "Calgary International, AB (YYC)",
      "Chicago O'Hare, IL (ORD)",
      "Los Angeles International, CA (LAX)",
      "New York John F Kennedy International, NY (JFK)",
      "San Francisco International, CA (SFO)",
      "Toronto Lester B Pearson, ON (YYZ)",
      "Vancouver International, BC (YVR)"
    ]
    @default_from = origin_airport.name
    @to = sort_destinations(results["destinations"])

    respond_to do |format|
      format.html
      format.json { render :json => { :combinations => @combinations, :from => @from, :to => @to } }
    end
  end

  def filter
    destination_name = params[:to]

    if params["segment"] == "Going"
      origin_airport = Airport.find_by_name(params[:from])
      origin_code = origin_airport.code

      params[:to] = params[:to] == "Any" ? 0 : Airport.find_by_name(params[:to]).id
      params[:from] = origin_airport.id
    else
      origin_airport = Airport.find_by_name(params[:to])
      origin_code = origin_airport.code

      params[:to] = Airport.find_by_name(params[:from]).id
      params[:from] = origin_airport.id

      @returning = true
    end


    params_to_send = {
      :password => ENV['POST_PASSWORD'],
      :passed_params => params
    }

    current_airports = [
      "JFK",
      "LAX",
      "ORD",
      "SFO",
      "YVR",
      "YYC",
      "YYZ"
    ]

    if current_airports.include?(origin_code)
      results = JSON.parse(RestClient.get "http://fs-#{origin_code.downcase}-api.herokuapp.com/filter", { :params => params_to_send })
      # results = JSON.parse(RestClient.get "http://localhost:3001/filter", { :params => params_to_send })
      @flights = results["flights"]

      destinations = sort_destinations(results["destinations"])

      @user = User.new
      @empty_search = @flights.empty? && !params[:scroll] ? true : false
      
      respond_to do |format|
        if @flights.any?
          format.json { render :json => { :flights => render_to_string('_flights.html.erb'), :destinations => destinations, :destination_name => destination_name } }
        elsif @empty_search
          format.json { render :json => { :flights => render_to_string('_flights.html.erb'), :destinations => destinations, :destination_name => destination_name, :noMoreFlights => true } }
        else
          format.json { render :json => { :flights => "<div class='no-more-flights label label-info'>No more flights to show</div>", :destinations => destinations, :destination_name => destination_name, :noMoreFlights => true } }
        end
      end
    else
      respond_to do |format|
        @empty_search = true
        format.json { render :json => { :flights => render_to_string('_flights.html.erb'), :destinations => [], :destination_name => "", :noMoreFlights => true } }
      end
    end
  end

  def visited
    session[:visited] = true
    respond_to do |format|
      format.json { render :json => "Done" }
    end
  end

  private

  def sort_destinations(arr)
    arr.map{ |airport_id| Airport.find(airport_id).name }.sort.unshift("Any")
  end
end

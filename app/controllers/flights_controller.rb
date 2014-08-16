require 'csv'
require 'will_paginate/array'

class FlightsController < ApplicationController
  def index
    # Geomatch index
    geomatch_city = {
      "Chicago" => "MDW",
      "Dallas" => "DFW",
      "Fort Lauderdale" => "FLL",
      "Long Beach" => "LGB",
      "Los Angeles" => "LAX",
      "New York City" => "LGA",
      "Oakland" => "OAK",
      "Orlando" => "MCO",
      "San Diego" => "SAN",
      "San Jose" => "SJC"
    }

    geomatch_region = {
      "Alberta" => "YYC",
      "Arizona" => "PHX",
      "British Columbia" => "YVR",
      "California" => "SFO",
      "Colorado" => "DEN",
      "Florida" => "MIA",
      "Georgia" => "ATL",
      "Hawaii" => "HNL",
      "Illinois" => "ORD",
      "Maryland" => "BWI",
      "Massachusetts" => "BOS",
      "Michigan" => "DTW",
      "Nevada" => "LAS",
      "New Jersey" => "EWR",
      "New York" => "JFK",
      "North Carolina " => "CLT",
      "Ontario" => "YYZ",
      "Texas" => "IAH",
      "Virginia" => "IAD",
      "Washington" => "SEA",
      "Washington D.C." => "DCA"
    }

    # Seeing if there's a geocode match
    Geocoder.configure(:timeout => 3)
    request_data = request.location.data if request.location
    # request_data = Geocoder.search("74.212.154.18")[0].data # Test for Los Angeles
    # request_data = Geocoder.search("99.140.218.14")[0].data # Test for Illinois
    if request_data
      origin_code = geomatch_city[request_data["city"]]
      origin_code ||= geomatch_region[request_data["region_name"]]
    end

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
      "Atlanta Hartsfield-Jackson ATL, GA (ATL)",
      "Baltimore Washington Int'l, MD (BWI)",
      "Boston Logan International, MA (BOS)",
      "Calgary International, AB (YYC)",
      "Charlotte Douglas, NC (CLT)",
      "Chicago Midway, IL (MDW)",
      "Chicago O'Hare, IL (ORD)",
      "Dallas/Ft Worth International, TX (DFW)",
      "Denver International, CO (DEN)",
      "Detroit Wayne County, MI (DTW)",
      "Fort Lauderdale International, FL (FLL)",
      "Honolulu International, HI (HNL)",
      "Houston George Bush Intercntl, TX (IAH)",
      "Las Vegas Mccarran International, NV (LAS)",
      "Long Beach Municipal, CA (LGB)",
      "Los Angeles International, CA (LAX)",
      "Miami International, FL (MIA)",
      "New York John F Kennedy International, NY (JFK)",
      "New York La Guardia, NY (LGA)",
      "New York Newark Liberty International, NJ (EWR)",
      "Oakland Metropolitan Oak International, CA (OAK)",
      "Orlando International, FL (MCO)",
      "Phoenix Sky Harbor Int'l, AZ (PHX)",
      "Ronald Reagan Washington Nat'l, DC (DCA)",
      "San Diego Lindberg Field, CA (SAN)",
      "San Francisco International, CA (SFO)",
      "San Jose Norman Y. Mineta International, CA (SJC)",
      "Seattle/Tacoma Sea/Tac, WA (SEA)",
      "Toronto Lester B Pearson, ON (YYZ)",
      "Vancouver International, BC (YVR)",
      "Washington Dulles International, DC (IAD)"
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
      "ATL",
      "BOS",
      "BWI",
      "CLT",
      "DCA",
      "DEN",
      "DFW",
      "DTW",
      "EWR",
      "FLL",
      "HNL",
      "IAD",
      "IAH",
      "JFK",
      "LAS",
      "LAX",
      "LGA",
      "LGB",
      "MCO",
      "MDW",
      "MIA",
      "OAK",
      "ORD",
      "PHX",
      "SAN",
      "SEA",
      "SFO",
      "SJC",
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

  def routes_to_scrape
    respond_to do |format|
      if params[:password] == ENV['POST_PASSWORD']
        routes = []
        Dir[Rails.root.join("db/routes/#{params[:code]}/*.csv")].each do |file|
          CSV.foreach(file) do |route|
            routes << [route[0], route[1]]
          end
        end
        format.json { render :json => { "routes" => routes.uniq } }
      else
        format.json { render :json => { "message" => "Whatcha tryin' to pull?" } }
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

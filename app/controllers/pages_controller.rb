class PagesController < ApplicationController
	def index
    render :layout => false
  end

  def about_us
	end

  def fbtest
  end

  def best_roundtrips
    @cheapest_analysis = {}
    Flight.where("shortcut = ? AND cheapest_price > ?", true, 0).group(:departure_airport_id, :arrival_airport_id).count.each do |flight_group|

      flights = Flight.where(:departure_airport_id => flight_group[0][0], :arrival_airport_id => flight_group[0][1])

      if flights.any?
        flight = flights.sort_by { |flight| [flight.price, flight.departure_time] }.first
        origin_depart = flight.departure_airport.code
        origin_arrive = flight.arrival_airport.code
        cheapest_return = Flight.where("shortcut = ? AND cheapest_price > ? AND departure_airport_id = ? AND arrival_airport_id = ? AND departure_time > ?", true, 0, flight.arrival_airport_id, flight.departure_airport_id, flight.departure_time).order("price ASC")[0]

        if cheapest_return
          @cheapest_analysis["#{origin_depart} - #{origin_arrive}"] ||= [9999999, 0, 9999999, 0, 0]
          if flight.price < @cheapest_analysis["#{origin_depart} - #{origin_arrive}"][0]
            @cheapest_analysis["#{origin_depart} - #{origin_arrive}"][0] = flight.price
            @cheapest_analysis["#{origin_depart} - #{origin_arrive}"][1] = flight.departure_time
          end
          if cheapest_return.price < @cheapest_analysis["#{origin_depart} - #{origin_arrive}"][2]
            @cheapest_analysis["#{origin_depart} - #{origin_arrive}"][2] = cheapest_return.price
            @cheapest_analysis["#{origin_depart} - #{origin_arrive}"][3] = cheapest_return.departure_time
          end
        end
      end
    end
    @cheapest_analysis.each do |k, v|
      v[4] = v[0] + v[2]
    end
  end

  def ga_test
  end

  def signups
    @users = User.all
  end
end
require 'csv'

desc "Analyze the cheapest round trips"

task :cheapest_analysis => :environment do
  cheapest_analysis = {}
  Flight.where("shortcut = ? AND cheapest_price > ?", true, 0).order("departure_time ASC").each do |flight|
    origin_depart = flight.departure_airport.code
    origin_arrive = Airport.find(flight.second_flight_destination).code

    puts "Analyzing: #{origin_depart} - #{origin_arrive}"

    cheapest_return = Flight.where("shortcut = ? AND cheapest_price > ? AND departure_airport_id = ? AND arrival_airport_id = ?", true, 0, flight.arrival_airport_id, flight.departure_airport_id).order("price ASC")

    if cheapest_return.any?
      cheapest_analysis["#{origin_depart} - #{origin_arrive}"] ||= [9999999, 0, 9999999, 0]
      if flight.price < cheapest_analysis["#{origin_depart} - #{origin_arrive}"][0]
        cheapest_analysis["#{origin_depart} - #{origin_arrive}"][0] = flight.price
        cheapest_analysis["#{origin_depart} - #{origin_arrive}"][1] = flight.departure_time
      end
      if cheapest_return[0].price < cheapest_analysis["#{origin_depart} - #{origin_arrive}"][2]
        cheapest_analysis["#{origin_depart} - #{origin_arrive}"][2] = cheapest_return[0].price
        cheapest_analysis["#{origin_depart} - #{origin_arrive}"][3] = cheapest_return[0].departure_time
      end
    end
  end
  CSV.open("db/cheapest_routes.csv", "wb") do |csv|
    csv << ["Route", "Going price", "Going date", "Returning price", "Returning date"]
    cheapest_analysis.sort_by { |s| s[0] }.each do |route, stats|
      csv << [route, stats[0], stats[1], stats[2], stats[3]]
    end
  end
end
require 'csv'

desc "Analyze the cheapest round trips"

task :cheapest_analysis => :environment do
  cheapest_analysis = {}
  Flight.where("shortcut = ? AND cheapest_price > ?", true, 0).order("departure_time ASC").each do |flight|
    origin_depart = flight.departure_airport.code
    origin_arrive = flight.arrival_airport.code

    puts "Analyzing: #{origin_depart} - #{origin_arrive}"

    cheapest_return = Flight.where("shortcut = ? AND cheapest_price > ? AND departure_airport_id = ? AND arrival_airport_id = ?", true, 0, flight.arrival_airport_id, flight.departure_airport_id).order("price ASC")[0]

    if cheapest_return
      cheapest_analysis["#{origin_depart} - #{origin_arrive}"] ||= [9999999, 0, 9999999, 0, 0]
      if flight.price < cheapest_analysis["#{origin_depart} - #{origin_arrive}"][0]
        cheapest_analysis["#{origin_depart} - #{origin_arrive}"][0] = flight.price
        cheapest_analysis["#{origin_depart} - #{origin_arrive}"][1] = flight.departure_time
      end
      if cheapest_return.price < cheapest_analysis["#{origin_depart} - #{origin_arrive}"][2] && cheapest_return.departure_time > flight.departure_time
        cheapest_analysis["#{origin_depart} - #{origin_arrive}"][2] = cheapest_return.price
        cheapest_analysis["#{origin_depart} - #{origin_arrive}"][3] = cheapest_return.departure_time
      end
    end
  end

  cheapest_analysis.each do |k, v|
    v[4] = v[0] + v[2]
  end

  CSV.open("db/cheapest_routes.csv", "wb") do |csv|
    csv << ["Route", "Going price", "Going date", "Returning price", "Returning date", "Total price"]
    cheapest_analysis.sort_by { |s| s[0] }.each do |route, stats|
      csv << [route, stats[0], stats[1], stats[2], stats[3], stats[4]]
    end
  end
end
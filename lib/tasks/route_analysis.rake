require 'csv'

desc "Analyze which routes to keep"

task :route_analysis => :environment do
  direct_analysis = {}
  Flight.where(:shortcut => true).each do |flight|
    origin_airport = flight.departure_airport.code
    second_flight = flight.arrival_airport.code
    direct_analysis["#{origin_airport} - #{second_flight}"] ||= [0, 0]
    direct_analysis["#{origin_airport} - #{second_flight}"][1] += 1
    direct_analysis["#{origin_airport} - #{second_flight}"][0] += 1 if flight.epic
  end
  CSV.open("db/direct_routes.csv", "wb") do |csv|
    csv << ["Route", "Epic Count", "Shortcut Count"]
    direct_analysis.sort_by { |s| s[1] }.reverse.each do |route, stats|
      csv << [route, stats[0], stats[1]]
    end
  end

  shortcut_analysis = {}
  Flight.where(:shortcut => true).each do |flight|
    origin_airport = flight.departure_airport.code
    second_flight = Airport.find(flight.second_flight_destination).code 
    shortcut_analysis["#{origin_airport} - #{second_flight}"] ||= [0, 0]
    shortcut_analysis["#{origin_airport} - #{second_flight}"][1] += 1
    shortcut_analysis["#{origin_airport} - #{second_flight}"][0] += 1 if flight.epic
  end
  CSV.open("db/hidden_routes.csv", "wb") do |csv|
    csv << ["Route", "Epic Count", "Shortcut Count"]
    shortcut_analysis.sort_by { |s| s[1] }.reverse.each do |route, stats|
      csv << [route, stats[0], stats[1]]
    end
  end
end
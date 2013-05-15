require 'csv'
require 'rest_client'

start_time = Time.now
flight_count = 0

# Uncomment the airports only if you are doing a first-time seed

# Airport.destroy_all

# CSV.foreach('db/airports.csv') do |row|
#   Airport.create( :name => row[1].strip,
#                   :code => row[2].strip,
#                   :latitude => row[3].strip,
#                   :longitude => row[4].strip,
#                   :timezone => row[5].strip)
# end

Dir[Rails.root.join('db/routes/*.csv')].each do |file|
  origin_code = file.split('/').last[0..2]
  date_array = []

  num_days = (1..90).to_a

  num_days.each do |num|
    date_array << (Time.now + num.days).strftime('%m/%d/%Y')
  end

  puts "*" * 50
  puts "Scraping flights originating from #{origin_code}"

  Flight.where(:origin_code => origin_code, :pure_date => (Time.now - 1.day).strftime('%m/%d/%Y')).destroy_all

  date_array.each do |date|
    non_stop_flights = []
    incomplete_flights = []

    Flight.where(:origin_code => origin_code, :pure_date => date).destroy_all

    CSV.foreach(file) do |route|
      begin
        origin = route[0]
        origin_airport_id = Airport.find_by_code(origin).id
        destination = route[1]
        destination_airport_id = Airport.find_by_code(destination).id
        formatted_date = date.split("/").rotate(2).join("-")
        cheapest_price = nil

        puts "*" * 50
        puts "#{origin}-#{destination}-#{date}"
        puts "*" * 50

        search_result = JSON.parse(RestClient.get 'http://travel.travelocity.com/flights/FlightsItineraryService.do', params: { jsessionid: 'ACEE3FCA20509BA3931D4E79C822E310.pwbap099a', flightType: 'oneway', dateTypeSelect: 'EXACT_DATES', leavingDate: date, leavingFrom: origin, goingTo: destination, dateLeavingTime: 1200, originalLeavingTime: 'Anytime', adults: 1, seniors: 0, children: 0, paxCount: 1, classOfService: 'ECONOMY', fareType: 'all', membershipLevel: 'NO_VALUE' })
        itins = search_result["results"]

        itins.each do |itin|
          begin
            if itin["numberOfStops"] == 0
              created_flight = Flight.create! do |fl|
                fl.departure_airport_id = origin_airport_id
                fl.arrival_airport_id = destination_airport_id
                fl.departure_time = DateTime.strptime(formatted_date + '-' + itin["departureTimeDisplay"], '%Y-%m-%d-%I:%M %p')
                fl.arrival_time = DateTime.strptime(formatted_date + '-' + itin["arrivalTimeDisplay"], '%Y-%m-%d-%I:%M %p')
                fl.arrival_time = fl.arrival_time + 1.day if fl.arrival_time < fl.departure_time
                fl.airline = itin["airline"]
                fl.flight_no = itin["header"][0]["flightNumber"]
                fl.price = (itin['totalFare'].to_f * 100).to_i
                fl.number_of_stops = 0
                fl.is_first_flight = true
                fl.pure_date = date
              end

              non_stop_flights << created_flight
              cheapest_price = created_flight.price if (cheapest_price == nil || created_flight.price < cheapest_price)

              puts "Scraped Non-stop #{itin["airline"]} #{itin["header"][0]["flightNumber"]}"
              flight_count += 1

            elsif itin["numberOfStops"] == 1
              flight = Flight.create! do |fl|
                fl.departure_airport_id = origin_airport_id
                fl.departure_time = DateTime.strptime(formatted_date + '-' + itin['departureTimeDisplay'], '%Y-%m-%d-%I:%M %p')
                fl.airline = itin['header'][0]['airline']
                fl.flight_no = itin['header'][0]['flightNumber']
                fl.price = (itin['totalFare'].to_f * 100).to_i
                fl.number_of_stops = 1
                fl.is_first_flight = true
                fl.pure_date = date
                fl.second_flight_destination = destination_airport_id
                fl.second_flight_no = itin['header'][1]['flightNumber']
              end

              incomplete_flights << flight
              cheapest_price = flight.price if (cheapest_price == nil || flight.price < cheapest_price)

              puts "Scraped One-stop #{itin['header'][0]['airline']} #{itin['header'][0]['flightNumber']} and #{itin['header'][1]['flightNumber']}"
              flight_count += 2
            end
          rescue
            created_flight.destroy if created_flight
            flight.destroy if flight
          end
        end
        Route.create! do |route|
          route.origin_airport_id = origin_airport_id
          route.destination_airport_id = destination_airport_id
          route.cheapest_price = cheapest_price
          route.date = date
        end
      rescue
      end
    end

    puts "*" * 50
    puts "Filling in one-stop flight info..."

    potential_shortcuts = []
    orphaned_flights = []
    shortcuts = []
    almost_shortcuts = []
    non_shortcuts = []

    incomplete_flights.each do |flight|
      match = non_stop_flights.select { |ns_flight| ns_flight.flight_no == flight.flight_no && ns_flight.airline == flight.airline && ns_flight.pure_date == flight.pure_date }[0]
      if match
        flight.update_attributes(:arrival_airport_id => match.arrival_airport_id, :arrival_time => match.arrival_time)
        potential_shortcuts << flight
      else
        orphaned_flights << flight
      end
    end

    puts "Deleting orphaned one-stop flights..."
    orphaned_flights.map { |flight| flight.destroy }

    puts "Commencing shortcut calculations..."

    all_flights = non_stop_flights + potential_shortcuts

    potential_shortcuts.each do |flight|
      similar_flights = all_flights.select { |all_flight| all_flight.flight_no == flight.flight_no && all_flight.airline == flight.airline && all_flight.pure_date == flight.pure_date }
      similar_flights.sort! { |flight| flight.price }

      cheapest_flight = similar_flights.first
      non_stop_flight = similar_flights.find {|f| f.number_of_stops == 0 }

      if non_stop_flight && cheapest_flight.price < (non_stop_flight.price - 2000) && !cheapest_flight.non_stop?
        cheapest_flight.update_attributes(:original_price => non_stop_flight.price, :origin_code => origin_code, :shortcut => true)
        shortcuts << cheapest_flight
        almost_shortcuts << flight unless flight == cheapest_flight
      else
        non_shortcuts << flight
      end
    end

    if shortcuts.any?
      puts "Deleting non-shortcut flights..."
      non_stop_flights.map { |flight| flight.destroy }
      non_shortcuts.map { |flight| flight.destroy }
      almost_shortcuts.map { |flight| flight.destroy }

      puts "Calculating epic wins..."

      shortcuts.uniq! { |flight| flight.flight_no + flight.airline + flight.pure_date }
      shortcuts.each do |flight|
        route = Route.where(:origin_airport_id => flight.departure_airport_id, :destination_airport_id => flight.arrival_airport_id, :date => flight.pure_date)[0]
        if (route.cheapest_price - flight.price) > 2000
          flight.update_attributes(:cheapest_price => route.cheapest_price, :epic => true)
        else
          flight.update_attributes(:cheapest_price => route.cheapest_price)
        end
      end

      shortcuts.map { |flight| flight.destroy unless flight.cheapest_price }

      puts "#{origin_code} #{date} complete."
    else
      puts "No shortcuts found - deleting all flights on this itinerary..."
      all_flights.map { |flight| flight.destroy }
    end
  end
end

puts "*" * 50
puts "Destroying all routes..."

Route.destroy_all

time = (Time.now - start_time).to_i
puts "*" * 50
puts "Total time: #{time / 60} minutes, #{time % 60} seconds"
puts "Flights: #{flight_count}"
puts "Shortcuts: #{Flight.count}"
puts "Flights scraped per second: #{(flight_count / (Time.now - start_time)).round(2)}"

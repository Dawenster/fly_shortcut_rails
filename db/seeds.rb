require 'csv'
require 'rest_client'

start_time = Time.now
flight_count = 0

Airport.destroy_all

CSV.foreach('db/airports.csv') do |row|
  Airport.create( :name => row[1].strip,
                  :code => row[2].strip,
                  :latitude => row[3].strip,
                  :longitude => row[4].strip,
                  :timezone => row[5].strip)
end

Dir[Rails.root.join('db/routes/*.csv')].each do |file|
  origin_code = file.split('/').last[0..2]
  date_array = []
  num_days = (1..20).to_a

  num_days.each do |num|
    date_array << (Time.now + num.days).strftime('%m/%d/%Y')
  end

  puts "*" * 50
  puts "Scraping flights originating from #{origin_code}"

  Flight.where(:origin_code => origin_code).destroy_all

  date_array.each do |date|
    non_stop_flights = []
    incomplete_flights = []
    flights_to_delete = []

    CSV.foreach(file) do |route|
      begin

        origin = route[0]
        origin_airport_id = Airport.find_by_code(origin).id

        destination = route[1]
        destination_airport_id = Airport.find_by_code(destination).id

        formatted_date = date.split("/").rotate(2).join("-")

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

              puts "Scraped Non-stop #{itin["airline"]} #{itin["header"][0]["flightNumber"]}"
              flight_count += 1
            end

            if itin["numberOfStops"] == 1
              next_day = false

              flight1 = Flight.create! do |fl|
                fl.departure_airport_id = origin_airport_id
                fl.departure_time = DateTime.strptime(formatted_date + '-' + itin['departureTimeDisplay'], '%Y-%m-%d-%I:%M %p')
                fl.airline = itin['header'][0]['airline']
                fl.flight_no = itin['header'][0]['flightNumber']
                fl.price = (itin['totalFare'].to_f * 100).to_i
                fl.number_of_stops = 1
                fl.is_first_flight = true
                fl.pure_date = date
              end

              flight2 = Flight.create! do |fl|
                fl.arrival_airport_id = destination_airport_id
                fl.airline = itin['header'][1]['airline']
                fl.flight_no = itin['header'][1]['flightNumber']
                fl.price = (itin['totalFare'].to_f * 100).to_i
                fl.number_of_stops = 1
                fl.is_first_flight = false
                fl.pure_date = date
              end
              
              flight1.update_attributes(:second_flight_destination => flight2.arrival_airport_id, :second_flight_no => flight2.flight_no)

              incomplete_flights << flight1
              flights_to_delete << flight2

              puts "Scraped One-stop #{itin['header'][0]['airline']} #{itin['header'][0]['flightNumber']} and #{itin['header'][1]['flightNumber']}"
              flight_count += 2
            end
          rescue
            created_flight.destroy if created_flight
            flight1.destroy if flight1
            flight2.destroy if flight2
          end
        end
      rescue
      end
    end
    puts "*" * 50
    puts "Filling in one-stop flight info..."

    incomplete_flights.each do |flight|
      match = non_stop_flights.select { |ns_flight| ns_flight.flight_no == flight.flight_no && ns_flight.airline == flight.airline && ns_flight.pure_date == flight.pure_date }[0]
      flight.update_attributes(:arrival_airport_id => match.arrival_airport_id, :arrival_time => match.arrival_time) if match
    end

    puts "*" * 50
    puts "Commencing shortcut calculations..."

    flights = Flight.get_shortcuts(origin_code).uniq
    shortcut_flights_indices = flights.map { |flight| incomplete_flights.index(flight) }

    puts "Deleting non-shortcut flights..."

    non_stop_flights.map { |flight| flight.destroy }
    flights_to_delete.map { |flight| flight.destroy }
    incomplete_flights.each_with_index { |flight, i| flight.destroy unless shortcut_flights_indices.include?(i) }

    puts "#{origin_code} #{date} complete."
  end
end

time = (Time.now - start_time).to_i
puts "*" * 50
puts "Total time: #{time / 60} minutes, #{time % 60} seconds"
puts "Flights: #{flight_count}"
puts "Flights scraped per second: #{(flight_count / (Time.now - start_time)).round(2)}"




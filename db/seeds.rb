# require 'pry'
require 'csv'
require 'rest_client'

start_time = Time.now
flight_count = 0

Flight.destroy_all
Itinerary.destroy_all

# CSV.foreach('db/airports.csv') do |row|
#   Airport.create( :name => row[1].strip,
#                   :code => row[2].strip,
#                   :latitude => row[3].strip,
#                   :longitude => row[4].strip,
#                   :timezone => row[5].strip)
# end

CSV.foreach('db/routes.csv') do |route|

  origin = route[0]
  origin_airport_id = Airport.find_by_code(origin).id

  destination = route[1]
  destination_airport_id = Airport.find_by_code(destination).id

  date = route[2]
  formatted_date = date.split("/").rotate(2).join("-")

  puts "*" * 50
  puts "#{origin}-#{destination}-#{date}"
  puts "*" * 50

  begin
    search_result = JSON.parse(RestClient.get 'http://travel.travelocity.com/flights/FlightsItineraryService.do', params: { jsessionid: 'ACEE3FCA20509BA3931D4E79C822E310.pwbap099a', flightType: 'oneway', dateTypeSelect: 'EXACT_DATES', leavingDate: date, leavingFrom: origin, goingTo: destination, dateLeavingTime: 1200, originalLeavingTime: 'Anytime', adults: 1, seniors: 0, children: 0, paxCount: 1, classOfService: 'ECONOMY', fareType: 'all', membershipLevel: 'NO_VALUE' })

    rid = search_result["metadata"]["responseId"]
    itins = search_result["results"]

    itins.each do |itin|
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
        end

        puts "Scraped Non-stop #{itin["airline"]} #{itin["header"][0]["flightNumber"]}"
        flight_count += 1
      end

      if itin["numberOfStops"] == 1
        uid = itin["uniqueId"]

        begin
          itinerary = JSON.parse(RestClient.get 'http://travel.travelocity.com/flights/FlightsDetails.do', params: { jsessionid: '0', locLink: 'OUTBOUND|NAT1', ashopRid: rid, itins: uid, classOfService: 'ECONOMY', paxCount: 1, leavingFrom: origin, goingTo: destination })

          if itinerary['details'].length == 2
            first_flight = itinerary['details'][0]
            second_flight = itinerary['details'][1]
            next_day = false

            flight1 = Flight.create! do |fl|
              fl.departure_airport_id = origin_airport_id
              fl.arrival_airport_id = Airport.find_by_code(first_flight['details-arrivalLocation'][/\(...\)/].gsub(/\W/, '')).id
              fl.departure_time = DateTime.strptime(formatted_date + '-' + first_flight['details-departureTime'], '%Y-%m-%d-%I:%M %p')
              fl.arrival_time = DateTime.strptime(formatted_date + '-' + first_flight['details-arrivalTime'], '%Y-%m-%d-%I:%M %p')
              if fl.arrival_time < fl.departure_time
                fl.arrival_time += 1.day
                next_day = true
              end
              fl.airline = first_flight['details-airline']
              fl.flight_no = first_flight['details-flightNumber']
              fl.price = (first_flight['details-totalFare'].to_f * 100).to_i
              fl.number_of_stops = 1
              fl.is_first_flight = true
            end

            flight2 = Flight.create! do |fl|
              fl.departure_airport_id = Airport.find_by_code(second_flight['details-departureLocation'][/\(...\)/].gsub(/\W/, '')).id
              fl.arrival_airport_id = destination_airport_id
              fl.departure_time = DateTime.strptime(formatted_date + '-' + second_flight['details-departureTime'], '%Y-%m-%d-%I:%M %p')
              fl.arrival_time = DateTime.strptime(formatted_date + '-' + second_flight['details-arrivalTime'], '%Y-%m-%d-%I:%M %p')
              if next_day || fl.departure_time < flight1.arrival_time
                fl.departure_time += 1.day
                fl.arrival_time += 1.day
              end
              fl.arrival_time += 1.day if fl.arrival_time < fl.departure_time
              fl.airline = second_flight['details-airline']
              fl.flight_no = second_flight['details-flightNumber']
              fl.price = (second_flight['details-totalFare'].to_f * 100).to_i
              fl.number_of_stops = 1
              fl.is_first_flight = false
            end
            
            flight1.update_attributes(:second_flight_destination => flight2.arrival_airport_id, :second_flight_no => flight2.flight_no)

            puts "Scraped One-stop #{first_flight["details-airline"]} #{first_flight['details-flightNumber']} and #{second_flight['details-flightNumber']}"
            flight_count += 2
          end
        rescue
        end
      end
    end
  rescue
  end
end

time = (Time.now - start_time).to_i
puts "*" * 50
puts "Total time: #{time / 60} minutes, #{time % 60} seconds"
puts "Flights: #{flight_count}"
puts "Flights scraped per second: #{(flight_count / (Time.now - start_time)).round(2)}"

start_time = Time.now
puts "*" * 50
puts "Commencing shortcut calculations..."

flights = Flight.get_shortcuts.uniq

Flight.all.each do |flight|
  flight.destroy unless flights.include?(flight)
end

puts "Mission accomplished in #{(Time.now - start_time).round(2)} seconds"




require 'date'

CSV.foreach('db/airports.csv') do |row|
	Airport.create(	:name => row[1].strip,
									:code => row[2].strip,
									:latitude => row[3].strip,
									:longitude => row[4].strip,
									:timezone => row[5].strip)
end

Dir[Rails.root.join('db/csv/*.csv')].each do |file|
	origin = file.split('/').last[0..2]
	date = file[/\d{4}-\d{2}-\d{2}/]
	direct = file[/non/].present?

	CSV.foreach(file) do |flight|

		first_flight = (origin == flight[0])

		if first_flight
			@itinerary = Itinerary.create!
		end

		puts file
		departure_airport = Airport.find_by_code(flight[0])
		arrival_airport = Airport.find_by_code(flight[1])

		next unless departure_airport && arrival_airport

		created_flight = Flight.create! do |fl|
			fl.itinerary_id = @itinerary.id
			fl.departure_airport_id = departure_airport.id
			fl.arrival_airport_id = arrival_airport.id
			fl.departure_time = DateTime.strptime(date + '-' + flight[2], '%Y-%m-%d-%I:%M %p')
			fl.arrival_time = DateTime.strptime(date + '-' + flight[3], '%Y-%m-%d-%I:%M %p')
			fl.airline = flight[5]
			fl.flight_no = flight[4]
			fl.price = flight[6]
			fl.number_of_stops = direct ? 0 : 1
			fl.is_first_flight = first_flight
		end

		if origin == flight[0]
			@itinerary.update_attributes!(
				:date => created_flight.departure_time,
				:origin_airport_id => created_flight.departure_airport_id,
				:destination_airport_id => created_flight.arrival_airport_id)
		else
			@itinerary.update_attributes!(
				:destination_airport_id => created_flight.arrival_airport_id)
		end
	end
end


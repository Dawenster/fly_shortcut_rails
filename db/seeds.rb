require 'date'

CSV.foreach('db/csv/airports.csv') do |row|
	Airport.create(	:name => row[1].strip,
									:code => row[2].strip,
									:latitude => row[3].strip,
									:longitude => row[4].strip,
									:timezone => row[5].strip)
end

CSV.foreach('db/csv/filenames.csv') do |file|
	begin
	origin = file[0][0..2]
	date = file[0][/\d{4}-\d{2}-\d{2}/]

	CSV.foreach('db/csv/' + file[0]) do |flight|

		if origin == flight[0]
			Itinerary.create
		end

		puts file

		created_flight = Flight.create(
			:itinerary_id => Itinerary.last.id,
			:departure_airport_id => Airport.find_by_code(flight[0]).id,
			:arrival_airport_id => Airport.find_by_code(flight[1]).id,
			:departure_time => DateTime.strptime(date + '-' + flight[2], '%Y-%m-%d-%I:%M %p'),
			:arrival_time => DateTime.strptime(date + '-' + flight[3], '%Y-%m-%d-%I:%M %p'),
			:airline => flight[5],
			:flight_no => flight[4],
			:price => flight[6])

		if origin == flight[0]
			Itinerary.last.update_attributes(
				:date => created_flight.departure_time,
				:origin_airport_id => created_flight.departure_airport_id,
				:destination_airport_id => created_flight.arrival_airport_id)
		else
			Itinerary.last.update_attributes(
				:destination_airport_id => created_flight.arrival_airport_id)
		end
	end
	rescue
	end
end


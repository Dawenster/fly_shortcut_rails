require 'date'

CSV.foreach('db/airports.csv') do |row|
	Airport.create(	:name => row[1].strip,
									:code => row[2].strip,
									:latitude => row[3].strip,
									:longitude => row[4].strip,
									:timezone => row[5].strip)
end

CSV.foreach('filenames.csv') do |file|
	origin = file[0..2]
	date = file[/\d{4}-\d{2}-\d{2}/]

	CSV.foreach(file) do |flight|
		if origin == flight[0]
			Itinerary.create(:price => flight[6])
		end

		flight = Flight.create(
			:itinerary_id => Itinerary.last.id,
			:departure_airport_id => Airport.find_by_code(flight[0]),
			:arrival_airport_id => Airport.find_by_code(flight[1]),
			:departure_time => DateTime.strptime(date + '-' + flight[2], '%Y-%m-%d-%I:%M %p'),
			:arrival_time => DateTime.strptime(date + '-' + flight[3], '%Y-%m-%d-%I:%M %p'),
			:airline => flight[5],
			:flight_no => flight[4])

		if origin == flight[0]
			Itinerary.last.update_attributes(
				:date => flight.departure_time,
				:origin_airport_id => flight.departure_airport_id)
		else
			Itinerary.last.update_attributes(
				:destination_airport_id => flight.arrival_airport_id)
		end
	end
end

# ONE_DAY = 60*60*24
# ONE_HOUR = 60*60
# AIRLINES = ['American Airlines', 'Delta', 'Jet Blue', 'US Airways']
# JFK_FAUX_DESTINATIONS = [1026, 899, 92] # Toronto, DC, Boston
# IAH_FAUX_DESTINATIONS = [390, 660, 659] # Havana, Miami, Mexico City
# ORD_FAUX_DESTINATIONS = [717, 975, 190] # New York, St. Louis, Detroit

# (0..7).each do |days|
	
# 	# create direct flights on each day of the week
# 	(0..5).each do |hours|

# 		# DIRECT ONE-WAY

# 		jfk = Itinerary.create(	:date => Time.now.beginning_of_day + days * ONE_DAY + hours * ONE_HOUR,
# 														:price => 60000,
# 														:origin_airport_id => 924,
# 														:destination_airport_id => 717)

# 		jfk_flight = Flight.create(	:itinerary_id => jfk.id,
# 																:departure_airport_id => 924,
# 																:arrival_airport_id => 717,
# 																:departure_time => jfk.date,
# 																:arrival_time => jfk.date + 7 * ONE_HOUR,
# 																:airline => AIRLINES.sample,
# 																:flight_no => rand(100..999))

# 		iah = Itinerary.create(	:date => Time.now.beginning_of_day + days * ONE_DAY + hours * ONE_HOUR,
# 														:price => 40000,
# 														:origin_airport_id => 924,
# 														:destination_airport_id => 410)

# 		iah_flight = Flight.create(	:itinerary_id => iah.id,
# 																:departure_airport_id => 924,
# 																:arrival_airport_id => 410,
# 																:departure_time => iah.date,
# 																:arrival_time => iah.date + 3 * ONE_HOUR,
# 																:airline => AIRLINES.sample,
# 																:flight_no => rand(100..999))

# 		ord = Itinerary.create(	:date => Time.now.beginning_of_day + days * ONE_DAY + hours * ONE_HOUR,
# 														:price => 50000,
# 														:origin_airport_id => 924,
# 														:destination_airport_id => 145)

# 		ord_flight = Flight.create(	:itinerary_id => ord.id,
# 																:departure_airport_id => 924,
# 																:arrival_airport_id => 145,
# 																:departure_time => ord.date,
# 																:arrival_time => ord.date + 3 * ONE_HOUR,
# 																:airline => AIRLINES.sample,
# 																:flight_no => rand(100..999))

# 		# FAUX DESTINATIONS

# 		faux_jfk = Itinerary.create(:date => Time.now.beginning_of_day + days * ONE_DAY + hours * ONE_HOUR,
# 																:price => rand(50000..70000),
# 																:origin_airport_id => 924,
# 																:destination_airport_id => JFK_FAUX_DESTINATIONS.sample.to_i)

# 		real_jfk_flight = Flight.create(:itinerary_id => faux_jfk.id,
# 																		:departure_airport_id => jfk_flight.departure_airport_id,
# 																		:arrival_airport_id => jfk_flight.arrival_airport_id,
# 																		:departure_time => jfk_flight.departure_time,
# 																		:arrival_time => jfk_flight.arrival_time,
# 																		:airline => jfk_flight.airline,
# 																		:flight_no => jfk_flight.flight_no)

# 		drop_jfk_flight = Flight.create(:itinerary_id => faux_jfk.id,
# 																		:departure_airport_id => jfk_flight.arrival_airport_id,
# 																		:arrival_airport_id => faux_jfk.destination_airport_id,
# 																		:departure_time => jfk_flight.departure_time + 3 * ONE_HOUR,
# 																		:arrival_time => jfk_flight.arrival_time + 7 * ONE_HOUR,
# 																		:airline => jfk_flight.airline,
# 																		:flight_no => rand(100..999))

# 		faux_iah = Itinerary.create(:date => Time.now.beginning_of_day + days * ONE_DAY + hours * ONE_HOUR,
# 																:price => rand(30000..50000),
# 																:origin_airport_id => 924,
# 																:destination_airport_id => IAH_FAUX_DESTINATIONS.sample.to_i)

# 		real_iah_flight = Flight.create(:itinerary_id => faux_iah.id,
# 																		:departure_airport_id => iah_flight.departure_airport_id,
# 																		:arrival_airport_id => iah_flight.arrival_airport_id,
# 																		:departure_time => iah_flight.departure_time,
# 																		:arrival_time => iah_flight.arrival_time,
# 																		:airline => iah_flight.airline,
# 																		:flight_no => iah_flight.flight_no)

# 		drop_iah_flight = Flight.create(:itinerary_id => faux_iah.id,
# 																		:departure_airport_id => iah_flight.arrival_airport_id,
# 																		:arrival_airport_id => faux_iah.destination_airport_id,
# 																		:departure_time => iah_flight.departure_time + 3 * ONE_HOUR,
# 																		:arrival_time => iah_flight.arrival_time + 7 * ONE_HOUR,
# 																		:airline => iah_flight.airline,
# 																		:flight_no => rand(100..999))

# 		faux_ord = Itinerary.create(:date => Time.now.beginning_of_day + days * ONE_DAY + hours * ONE_HOUR,
# 																:price => rand(40000..60000),
# 																:origin_airport_id => 924,
# 																:destination_airport_id => ORD_FAUX_DESTINATIONS.sample.to_i)

# 		real_ord_flight = Flight.create(:itinerary_id => faux_ord.id,
# 																		:departure_airport_id => ord_flight.departure_airport_id,
# 																		:arrival_airport_id => ord_flight.arrival_airport_id,
# 																		:departure_time => ord_flight.departure_time,
# 																		:arrival_time => ord_flight.arrival_time,
# 																		:airline => ord_flight.airline,
# 																		:flight_no => ord_flight.flight_no)

# 		drop_ord_flight = Flight.create(:itinerary_id => faux_ord.id,
# 																		:departure_airport_id => ord_flight.arrival_airport_id,
# 																		:arrival_airport_id => faux_ord.destination_airport_id,
# 																		:departure_time => ord_flight.departure_time + 3 * ONE_HOUR,
# 																		:arrival_time => ord_flight.arrival_time + 7 * ONE_HOUR,
# 																		:airline => ord_flight.airline,
# 																		:flight_no => rand(100..999))
# 	end
# end
	

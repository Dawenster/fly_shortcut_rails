class Flight < ActiveRecord::Base
  attr_accessible :airline, :arrival_airport_id, :arrival_time, :departure_airport_id, :departure_time, :flight_no, :itinerary_id

  belongs_to 	:itinerary

	belongs_to 	:airport,
							:class_name => Airport,
							:foreign_key => 'departure_airport_id'

	belongs_to 	:airport,
							:class_name => Airport,
							:foreign_key => 'arrival_airport_id'
end
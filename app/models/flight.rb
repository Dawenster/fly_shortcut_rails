class Flight < ActiveRecord::Base
  attr_accessible :airline, :arrival_airport_id, :arrival_time, :departure_airport_id, :departure_time, :flight_no, :itinerary_id,
                  :price, :number_of_stops, :uid, :rid, :is_first_flight, :second_flight_destination, :second_flight_no,
                  :original_price, :origin_code, :shortcut, :pure_date, :cheapest_price, :epic, :month, :new

  belongs_to 	:itinerary,
  						:counter_cache => true

	belongs_to 	:departure_airport,
							:class_name => Airport,
							:foreign_key => 'departure_airport_id'

	belongs_to 	:arrival_airport,
							:class_name => Airport,
							:foreign_key => 'arrival_airport_id'

  def non_stop?
    number_of_stops == 0
  end

  def rounded_price
    (price / 100).round(0)
  end
end

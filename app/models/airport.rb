class Airport < ActiveRecord::Base
  attr_accessible :code, :latitude, :longitude, :name, :timezone

  has_one :itinerary, 
					:class_name => Itinerary, 
					:foreign_key => 'origin_city_id'

	has_one :itinerary, 
					:class_name => Itinerary, 
					:foreign_key => 'destination_city_id'

	has_one :flight, 
					:class_name => Flight, 
					:foreign_key => 'departure_city_id'

	has_one :flight, 
					:class_name => Flight, 
					:foreign_key => 'arrival_city_id'
end

ActiveRecord::Schema.define(:version => 20130430065736) do

  create_table "airports", :force => true do |t|
    t.string   "code"
    t.string   "name"
    t.string   "latitude"
    t.string   "longitude"
    t.string   "timezone"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "flights", :force => true do |t|
    t.integer  "itinerary_id"
    t.integer  "departure_airport_id"
    t.integer  "arrival_airport_id"
    t.datetime "departure_time"
    t.datetime "arrival_time"
    t.string   "airline"
    t.string   "flight_no"
    t.integer  "price"
    t.integer  "number_of_stops"
    t.boolean  "is_first_flight"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
    t.integer  "second_flight_destination"
    t.integer  "second_flight_no"
    t.integer  "original_price"
  end

  add_index "flights", ["arrival_airport_id"], :name => "index_flights_on_arrival_airport_id"
  add_index "flights", ["departure_airport_id"], :name => "index_flights_on_departure_airport_id"
  add_index "flights", ["itinerary_id"], :name => "index_flights_on_itinerary_id"

  create_table "itineraries", :force => true do |t|
    t.datetime "date"
    t.integer  "origin_airport_id"
    t.integer  "destination_airport_id"
    t.integer  "original_price"
    t.datetime "created_at",             :null => false
    t.datetime "updated_at",             :null => false
    t.integer  "flights_count"
  end

  add_index "itineraries", ["destination_airport_id"], :name => "index_itineraries_on_destination_airport_id"
  add_index "itineraries", ["origin_airport_id"], :name => "index_itineraries_on_origin_airport_id"

end
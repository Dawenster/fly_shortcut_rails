# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20131214022132) do

  create_table "airports", :force => true do |t|
    t.string   "city"
    t.string   "name"
    t.string   "code"
    t.float    "latitude"
    t.float    "longitude"
    t.string   "timezone"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "cities", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "user_id"
    t.float    "latitude"
    t.float    "longitude"
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
    t.string   "uid"
    t.string   "rid"
    t.boolean  "is_first_flight"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
    t.integer  "second_flight_destination"
    t.integer  "second_flight_no"
    t.integer  "original_price"
    t.string   "origin_code"
    t.boolean  "shortcut"
    t.string   "pure_date"
    t.integer  "cheapest_price"
    t.boolean  "epic"
    t.string   "month"
    t.boolean  "new"
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

  create_table "routes", :force => true do |t|
    t.integer  "origin_airport_id"
    t.integer  "destination_airport_id"
    t.integer  "cheapest_price"
    t.string   "date"
    t.datetime "created_at",             :null => false
    t.datetime "updated_at",             :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "email"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

end

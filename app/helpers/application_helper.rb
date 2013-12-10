module ApplicationHelper
  def format_flight(flight_hash)
    flight_hash["departure_airport_id"] = flight_hash["departure_airport_id"].to_i
    flight_hash["arrival_airport_id"] = flight_hash["arrival_airport_id"].to_i
    flight_hash["departure_time"] = to_date(flight_hash["departure_time"])
    flight_hash["arrival_time"] = to_date(flight_hash["arrival_time"])
    flight_hash["price"] = flight_hash["price"].to_i
    flight_hash["number_of_stops"] = flight_hash["number_of_stops"].to_i
    flight_hash["is_first_flight"] = to_bool(flight_hash["is_first_flight"])
    flight_hash["second_flight_destination"] = flight_hash["second_flight_destination"].to_i
    flight_hash["second_flight_no"] = flight_hash["second_flight_no"].to_i
    flight_hash["original_price"] = flight_hash["original_price"].to_i
    flight_hash["shortcut"] = to_bool(flight_hash["shortcut"])
    flight_hash["cheapest_price"] = flight_hash["cheapest_price"].to_i
    flight_hash["epic"] = to_bool(flight_hash["epic"])
    flight_hash["new"] = to_bool(flight_hash["new"])
    return flight_hash
  end

  def non_stop?(flight_hash)
    flight_hash["number_of_stops"] == 0
  end

  def rounded_price(int)
    (int / 100).round(0)
  end

  def to_bool(str)
    str == "true" || str == true
  end

  def to_date(str)
    DateTime.strptime(str, "%Y-%m-%dT%H:%M:%S")
  end

  def special_epic(flight)
    route = Route.where("origin_airport_id = ? AND destination_airport_id = ?", flight["departure_airport_id"], flight["arrival_airport_id"])[0]
    if route
      return flight["price"] < route.cheapest_price
    else
      return false
    end
  end
end

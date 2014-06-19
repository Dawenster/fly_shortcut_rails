class OffsiteFlightsController < ApplicationController
  def redirect
    # shortcut_flight = Flight.find(params[:id])
    original = params[:original] == "true"
    pure_search = params[:pure_search] == "true"
    departure_airport_code = Airport.find(params[:departure_airport_id]).code
    departure_time = DateTime.strptime(params[:departure_time], "%Y-%m-%dT%H:%M:%S%z")
    uid = ""
    itin_id = ""

    if original
      arrival_airport_code = Airport.find(params[:arrival_airport_id]).code
      # search_result = search_result(departure_time.strftime('%m/%d/%Y'), departure_airport_code, arrival_airport_code)
      # flights = search_result["results"]
      # rid = search_result["metadata"]["responseId"]

      # flights.each do |flight|
      #   if flight["numberOfStops"].to_i == 0 && flight["airline"] == params["airline"] && flight["header"][0]["flightNumber"].to_i == params["flight_no"].to_i
      #     uid = flight["uniqueId"]
      #     itin_id = flight["itinId"]
      #   end
      # end
      # link = link(departure_airport_code, arrival_airport_code, departure_time, uid, itin_id, rid)
      link = pure_search_link(departure_airport_code, arrival_airport_code, departure_time)

    elsif pure_search == true
      arrival_airport_code = Airport.find(params[:arrival_airport_id]).code
      link = pure_search_link(departure_airport_code, arrival_airport_code, departure_time)

    else
      arrival_airport_code = Airport.find(params["second_flight_destination"]).code
      # search_result = search_result(departure_date, departure_airport_code, arrival_airport_code)
      # flights = search_result["results"]
      # rid = search_result["metadata"]["responseId"]

      # flights.each do |flight|
      #   if flight["numberOfStops"].to_i == 1 && flight["header"][0]["flightNumber"].to_i == shortcut_flight.flight_no.to_i && flight["header"][1]["flightNumber"].to_i == shortcut_flight.second_flight_no.to_i
      #     uid = flight["uniqueId"]
      #     itin_id = flight["itinId"]
      #   end
      # end
      # link = link(departure_airport_code, arrival_airport_code, shortcut_flight, uid, itin_id, rid)
      link = pure_search_link(departure_airport_code, arrival_airport_code, departure_time)
    end
    redirect_to link.to_param
  end

  def search_result(departure_date, departure_airport_code, arrival_airport_code)
    result = JSON.parse(RestClient.get 'http://travel.travelocity.com/flights/FlightsItineraryService.do', params: { jsessionid: 'ACEE3FCA20509BA3931D4E79C822E310.pwbap099a', flightType: 'oneway', dateTypeSelect: 'EXACT_DATES', leavingDate: departure_date, leavingFrom: departure_airport_code, goingTo: arrival_airport_code, dateLeavingTime: 1200, originalLeavingTime: 'Anytime', adults: 1, seniors: 0, children: 0, paxCount: 1, classOfService: 'ECONOMY', fareType: 'all', membershipLevel: 'NO_VALUE' })
  end

  def link(departure_airport_code, arrival_airport_code, departure_time, uid, itin_id, rid)
    # binding.pry
    "https://travel.travelocity.com/checkout/CheckoutReview.do;jsessionid=9F58E31C5F7BB60F0DB7D6BF30199626.pwbap118a?flightPath=TF&tripType=oneway#{(Time.now + 2.hours).to_s[0..18].gsub(/\D/,'')}&locLink=OUTBOUND|NAT1LDTB&flightType=oneway&dateTypeSelect=exactDates&adults=1&children=0&minorsAge0=%3F&minorsAge1=%3F&minorsAge2=%3F&minorsAge3=%3F&minorsAge4=%3F&seniors=0&classOfService=ECONOMY&fareType=all&membershipLevel=NO_VALUE&airlineSearchPref=&leavingFrom=#{departure_airport_code}&goingTo=#{arrival_airport_code}&leavingDate=#{departure_time.strftime('%m %d %Y').gsub(' ', '%2F')}&dateLeavingTime=Anytime&lastSelectedLeg=#{uid}&selectedLeg0=&selectedLeg1=&selectedLeg2=&itinId=#{itin_id}&rid=#{rid}&originalPrice=&originalTotalPrice="
  end

  def pure_search_link(departure_airport_code, arrival_airport_code, date)
    "http://www.travelocity.com/Flights-Search?trip=oneway&leg1=from:#{departure_airport_code},to:#{arrival_airport_code},departure:#{date.strftime('%m') + '%2f' + date.strftime('%d') + '%2f' + date.strftime('%Y')}TANYT&passengers=children:0,adults:1,seniors:0,infantinlap:Y&options=cabinclass:coach,nopenalty:N,sortby:price&mode=search"
  end
end

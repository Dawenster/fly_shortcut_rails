class OffsiteFlightsController < ApplicationController
  def redirect
    flight = Flight.find(params[:id])
    original = params[:original] == "true"
    departure_airport = flight.departure_airport

    if original
      original_flight = Flight.where(:flight_no => flight.flight_no, :airline => flight.airline, :number_of_stops => 0).first
      arrival_airport = original_flight.arrival_airport.code
      itin_id = original_flight.uid[0..1].gsub("-", "").gsub("_", "")

      link = "http://travel.travelocity.com/flights/CrossSellCheckoutHandOff.do;jsessionid=E1F995747D3C4538FC8DA80BF226B3DF.pwbap033a?flightPath=TF&tripType=oneway#{(Time.now + 2.hours).to_s[0..18].gsub(/\D/,'')}&flightType=oneway&dateTypeSelect=exactDates&adults=1&children=0&minorsAge0=%3F&minorsAge1=%3F&minorsAge2=%3F&minorsAge3=%3F&minorsAge4=%3F&seniors=0&classOfService=ECONOMY&fareType=all&membershipLevel=NO_VALUE&airlineSearchPref=&leavingFrom=#{departure_airport.code}&goingTo=#{arrival_airport}&leavingDate=#{flight.departure_time.strftime('%m %d %Y').gsub(' ', '%2F')}&dateLeavingTime=Anytime&originalLeavingTime=Anytime&lastSelectedLeg=#{original_flight.uid}&selectedLeg0=&selectedLeg1=&selectedLeg2=&itinId=#{itin_id}&rid=#{original_flight.rid}&originalPrice=&originalTotalPrice="
    else
      itinerary_destination = flight.itinerary.destination_airport
      itin_id = flight.uid[0..1].gsub("-", "").gsub("_", "")

      link = "http://travel.travelocity.com/flights/CrossSellCheckoutHandOff.do;jsessionid=E1F995747D3C4538FC8DA80BF226B3DF.pwbap033a?flightPath=TF&tripType=oneway#{(Time.now + 2.hours).to_s[0..18].gsub(/\D/,'')}&flightType=oneway&dateTypeSelect=exactDates&adults=1&children=0&minorsAge0=%3F&minorsAge1=%3F&minorsAge2=%3F&minorsAge3=%3F&minorsAge4=%3F&seniors=0&classOfService=ECONOMY&fareType=all&membershipLevel=NO_VALUE&airlineSearchPref=&leavingFrom=#{departure_airport.code}&goingTo=#{itinerary_destination.code}&leavingDate=#{flight.departure_time.strftime('%m %d %Y').gsub(' ', '%2F')}&dateLeavingTime=Anytime&originalLeavingTime=Anytime&lastSelectedLeg=#{flight.uid}&selectedLeg0=&selectedLeg1=&selectedLeg2=&itinId=#{itin_id}&rid=#{flight.rid}&originalPrice=&originalTotalPrice="
    end
    redirect_to link
  end
end

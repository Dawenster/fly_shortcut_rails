class OffsiteFlightsController < ApplicationController
  def redirect
    flight = Flight.find(params[:id])
    original = params[:original] == "true"
    departure_airport = flight.departure_airport
    itin_id = flight.uid[0]

    if original
      arrival_airport = flight.arrival_airport.code

      link = "https://travel.travelocity.com/checkout/CheckoutReview.do?flightPath=TF&tripType=oneway#{(Time.now + 4*60*60).to_s[0..18].gsub(/\D/,'')}&flightType=oneway&dateTypeSelect=exactDates&adults=1&children=0&minorsAge0=%3F&minorsAge1=%3F&minorsAge2=%3F&minorsAge3=%3F&minorsAge4=%3F&seniors=0&classOfService=ECONOMY&fareType=all&membershipLevel=NO_VALUE&airlineSearchPref=&leavingFrom=#{departure_airport.code}&goingTo=#{arrival_airport}&leavingDate=#{flight.departure_time.strftime('%m %d %Y').gsub(' ', '%2F')}&dateLeavingTime=Anytime&originalLeavingTime=Anytime&lastSelectedLeg=#{flight.uid}&selectedLeg0=&selectedLeg1=&selectedLeg2=&itinId=#{itin}&rid=#{flight.rid}&originalPrice=&originalTotalPrice="
    else
      itinerary_destination = flight.itinerary.destination_airport

      link = "https://travel.travelocity.com/checkout/CheckoutReview.do?flightPath=TF&tripType=oneway#{(Time.now + 4*60*60).to_s[0..18].gsub(/\D/,'')}&flightType=oneway&dateTypeSelect=exactDates&adults=1&children=0&minorsAge0=%3F&minorsAge1=%3F&minorsAge2=%3F&minorsAge3=%3F&minorsAge4=%3F&seniors=0&classOfService=ECONOMY&fareType=all&membershipLevel=NO_VALUE&airlineSearchPref=&leavingFrom=#{departure_airport.code}&goingTo=#{itinerary_destination.code}&leavingDate=#{flight.departure_time.strftime('%m %d %Y').gsub(' ', '%2F')}&dateLeavingTime=Anytime&originalLeavingTime=Anytime&lastSelectedLeg=#{flight.uid}&selectedLeg0=&selectedLeg1=&selectedLeg2=&itinId=#{itin}&rid=#{flight.rid}&originalPrice=&originalTotalPrice="
    end
    redirect_to link

  end
end

# require 'rubygems'
# require 'mechanize'
require 'open-uri'
# require 'csv'
# require 'pry'



CSV.foreach('db/airports.csv') do |row|
  Airport.create( :name => row[1].strip,
                  :code => row[2].strip,
                  :latitude => row[3].strip,
                  :longitude => row[4].strip,
                  :timezone => row[5].strip)
end

CSV.foreach('db/routes.csv') do |route|
  origin = route[0]
  destination = route[1]
  date = route[2]
  write_date = date.split("/").rotate(2).join("-")

  link =  "http://travel.travelocity.com/flights/InitialSearch.do?Service=TRAVELOCITY&last_pgd_page=ushpnbff.pgd&entryPoint=FD&pkg_type=fh_pkg&flightType=oneway&dateFormat=mm%2Fdd%2Fyyyy&subnav=form-fow&"
  link += "leavingFrom=" + origin
  link += "&goingTo=" + destination
  link += "&dateTypeSelect=exactDates&leavingDate="
  link += date.gsub('/', '%2F')  # "04%2F12%2F2013"
  link += "&dateLeavingTime=Anytime&departDateFlexibility=3&returningDate=mm%2Fdd%2Fyyyy&dateReturningTime=Anytime&returnDateFlexibility=3&adults=1&children=0&seniors=0&minorsAge0=%3F&minorsAge1=%3F&minorsAge2=%3F&minorsAge3=%3F&minorsAge4=%3F"

  doc = Nokogiri::HTML(open(link))

  scraper = Mechanize.new { |agent| agent.user_agent_alias = 'Mac Safari' }
  scraper.get(link) do |page|
    rid = page.search('#rid')
    binding.pry
  end
end

flight_link = 'http://travel.travelocity.com/flights/FlightsDetails.do;?locLink=OUTBOUND|NAT1&ashopRid=310522312246088&itins=2_84-70&classOfService=ECONOMY&paxCount=1&selectedDepartureAirport=&selectedArrivalAirport=&leavingFrom=SFO&goingTo=IAH'

rid
itins
310522312246088
require 'capybara-webkit'
require 'capybara'
require 'capybara/dsl'
require 'launchy'
require 'pry'
require 'csv'
require 'httparty'
require 'rest_client'

Capybara.default_driver = :webkit

CSV.foreach('db/airports.csv') do |row|
  Airport.create( :name => row[1].strip,
                  :code => row[2].strip,
                  :latitude => row[3].strip,
                  :longitude => row[4].strip,
                  :timezone => row[5].strip)
end

class Scraper
  include Capybara::DSL

  def initialize(dep, arr, date)
    @dep = dep
    @arr = arr
    @date = date
  end

  def visit_link(link)
    visit(link)
  end

  def non_stop
    if find('#stopsfilter-1 label').text == "Non-Stops"
      find('#stopsfilter-1-field').click
      return true
    else
      return false
    end
  end

  def one_stop
    if find('#stopsfilter-2 label').text == "1 Stops"
      find('#stopsfilter-2-field').click
    else
      find('#stopsfilter-1-field').click
    end
  end

  def carriers
    max = page.all('.carrier').length
    count = 0
    carriers = []
    while count < max
      text = page.all('.carrier')[count].text
      carriers << text
      count += 1
    end
    carriers
  end

  def flight_nums
    max = page.all('.flt-num').length
    count = 0
    flight_nums = []
    while count < max
      text = page.all('.flt-num')[count].text
      operated = text[/(operated)/]
      unless operated
        flight_num = text[/\d+/]
        flight_nums << flight_num
      end
      count += 1
    end
    flight_nums.select { |num| num != nil }
  end

  def departure_times
    max = page.all('.dpt-time').length
    count = 0
    departure_times = []
    while count < max
      text = page.all('.dpt-time')[count].text
      departure_time = text.gsub("Depart: ", "")
      departure_times << departure_time
      count += 1
    end
    departure_times.select { |time| time[0] != '[' }
  end

  def arrival_times
    max = page.all('.arv-time').length
    count = 0
    arrival_times = []
    while count < max
      text = page.all('.arv-time')[count].text
      arrival_time = text.gsub("Arrive: ", "")
      arrival_times << arrival_time
      count += 1
    end
    arrival_times.select { |time| time[0] != '[' }
  end

  def create_search_link(origin, destination, date)
    search_link =  "http://travel.travelocity.com/flights/InitialSearch.do?Service=TRAVELOCITY&last_pgd_page=ushpnbff.pgd&entryPoint=FD&pkg_type=fh_pkg&flightType=oneway&dateFormat=mm%2Fdd%2Fyyyy&subnav=form-fow&"
    search_link += "leavingFrom=" + origin
    search_link += "&goingTo=" + destination
    search_link += "&dateTypeSelect=exactDates&leavingDate="
    search_link += date.gsub('/', '%2F')  # "04%2F12%2F2013"
    search_link += "&dateLeavingTime=Anytime&departDateFlexibility=3&returningDate=mm%2Fdd%2Fyyyy&dateReturningTime=Anytime&returnDateFlexibility=3&adults=1&children=0&seniors=0&minorsAge0=%3F&minorsAge1=%3F&minorsAge2=%3F&minorsAge3=%3F&minorsAge4=%3F"  
  end

  def get_uids(non)
    uids = []
    page.all('h3').each { |h| uids << h['id'].gsub('airline-', '') if h['id'] && h['id'][/\d/] }
    if non
      uids = uids.map { |uid| uid.gsub(/-.+/, '') }
    else
      uids = uids.map { |uid| uid.gsub(/-0/, '') }
    end
    uids
  end

  def get_rid
    page.find('#rid').value
  end
end

# driver code

CSV.foreach('db/routes.csv') do |route|
  origin = route[0]
  destination = route[1]
  date = route[2]
  write_date = date.split("/").rotate(2).join("-")

  scraper = Scraper.new(origin, destination, date)

  search_link = scraper.create_search_link(origin, destination, date)
  scraper.visit_link(search_link)

  rid = scraper.get_rid
  scraper.non_stop
  uids = scraper.get_uids(true)

  # direct flights
  uids.each_with_index do |uid, i|
    itinerary = JSON.parse(RestClient.get 'http://travel.travelocity.com/flights/FlightsDetails.do', params: { jsessionid: '35E5BC6477D6898D3272577E2AE157E6.pwbap103a', locLink: 'OUTBOUND|NAT1', ashopRid: rid, itins: uid, classOfService: 'ECONOMY', paxCount: 1, leavingFrom: origin, goingTo: destination })

    if itinerary['details'].length == 1
      departures = scraper.departure_times
      arrivals = scraper.arrival_times
      airlines = scraper.carriers

      new_itin = Itinerary.create!(
        :origin_airport_id => Airport.find_by_code(origin).id,
        :destination_airport_id => Airport.find_by_code(destination).id)

      created_flight = Flight.create! do |fl|
        fl.itinerary_id = new_itin.id
        fl.departure_airport_id = new_itin.origin_airport_id
        fl.arrival_airport_id = new_itin.destination_airport_id
        fl.departure_time = DateTime.strptime(write_date + '-' + departures[i], '%Y-%m-%d-%I:%M %p')
        fl.arrival_time = DateTime.strptime(write_date + '-' + arrivals[i], '%Y-%m-%d-%I:%M %p')
        fl.airline = airlines[i]
        fl.flight_no = itinerary['details'][0]['details-flightNumber']
        fl.price = itinerary['details'][0]['details-totalFare']
        fl.number_of_stops = 0
        fl.is_first_flight = true
        fl.uid = uid
        fl.rid = rid
      end
      new_itin.update_attributes!(
        :date => created_flight.departure_time,
        :origin_airport_id => created_flight.departure_airport_id,
        :destination_airport_id => created_flight.arrival_airport_id)

    end
  end

  scraper.one_stop
  uids = scraper.get_uids(false)

  # one-stop flights
  uids.each_with_index do |uid, i|
    itinerary = JSON.parse(RestClient.get 'http://travel.travelocity.com/flights/FlightsDetails.do', params: { jsessionid: '35E5BC6477D6898D3272577E2AE157E6.pwbap103a', locLink: 'OUTBOUND|NAT1', ashopRid: rid, itins: uid, classOfService: 'ECONOMY', paxCount: 1, leavingFrom: origin, goingTo: destination })

    if itinerary['details'].length == 2
      new_itin = Itinerary.create!(
        :origin_airport_id => Airport.find_by_code(origin).id,
        :destination_airport_id => Airport.find_by_code(destination).id)

      first_flight = itinerary['details'][0]
      second_flight = itinerary['details'][1]

      flight1 = Flight.create! do |fl|
        fl.itinerary_id = new_itin.id
        fl.departure_airport_id = new_itin.origin_airport_id
        fl.arrival_airport_id = Airport.find_by_code(first_flight['details-arrivalLocation'][/\(...\)/].gsub(/\W/, '')).id
        fl.departure_time = DateTime.strptime(write_date + '-' + first_flight['details-departureTime'], '%Y-%m-%d-%I:%M %p')
        fl.arrival_time = DateTime.strptime(write_date + '-' + first_flight['details-arrivalTime'], '%Y-%m-%d-%I:%M %p')
        fl.airline = first_flight['details-airline']
        fl.flight_no = first_flight['details-flightNumber']
        fl.price = first_flight['details-totalFare']
        fl.number_of_stops = 1
        fl.is_first_flight = true
        fl.uid = uid
        fl.rid = rid
      end

      flight2 = Flight.create! do |fl|
        fl.itinerary_id = new_itin.id
        fl.departure_airport_id = Airport.find_by_code(second_flight['details-departureLocation'][/\(...\)/].gsub(/\W/, '')).id
        fl.arrival_airport_id = new_itin.destination_airport_id
        fl.departure_time = DateTime.strptime(write_date + '-' + second_flight['details-departureTime'], '%Y-%m-%d-%I:%M %p')
        fl.arrival_time = DateTime.strptime(write_date + '-' + second_flight['details-arrivalTime'], '%Y-%m-%d-%I:%M %p')
        fl.airline = second_flight['details-airline']
        fl.flight_no = second_flight['details-flightNumber']
        fl.price = second_flight['details-totalFare']
        fl.number_of_stops = 1
        fl.is_first_flight = false
        fl.uid = uid
        fl.rid = rid
      end
      binding.pry
    end
  end
end







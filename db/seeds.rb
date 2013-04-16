require 'capybara-webkit'
require 'capybara'
require 'capybara/dsl'
require 'launchy'
require 'pry'
require 'csv'

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

  def fill_in_form
    visit('http://travelocity.com/')
    find('#sub-nav-fow').click
    fill_in 'fo-from', with: @dep
    find('li', :text => @dep).first.click
    fill_in 'fo-to', with: @arr
    find('li', :text => @arr).first.click
    fill_in 'fo-fromdate', with: @date
    page.all('input.btn_alt')[0].click
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

  def get_select
    max = page.all('.action.select input').length
    count = 0
    select = []
    while count < max
      select << page.all('.action.select input')[count].id
      count += 1
    end
    select
  end

  def open
    max = page.all('.openDetails').length
    count = 0
    while count < max - 4
      page.all('.openDetails')[count].click
      count += 1
    end
  end

  def num_flights
    max = page.all('.stops').length
    count = 0
    num_flights = []
    while count < max - 4
      text = page.all('.stops')[count].text
      text = text[/\d/]
      if text == nil
        num_flights << 1
      elsif text == "1"
        num_flights << 2
      end
      count += 1
    end
    num_flights
  end

  def no_change_of_planes
    max = page.all('.connection').length
    count = 0
    flight_changes = []
    while count < max
      text = page.all('.connection')[count].text
      if text[-1] != ']'
        text = text[/Stop/]
        if text == nil
          flight_changes << "Connection"
        elsif text == "Stop"
          flight_changes << "Stop"
        end
      end
      count += 1
    end
    flight_changes
  end

  def amounts
    max = page.all('.amt').length
    count = 0
    nums = []
    while count < max - 4
      text = page.all('.amt')[count].text
      text = text[/\d+\.\d+/]
      num = (text.to_f * 100).to_i
      nums << num
      count += 1
    end
    nums
  end

  def departures
    max = page.all('.dpt-location').length
    count = 0
    departures = []
    while count < max
      text = page.all('.dpt-location')[count].text
      departure = text[/\(...\)/]
      unless departure == nil
        departure = departure.gsub(/\W/, '')
        departures << departure
      end
      count += 1
    end
    departures
  end

  def arrivals
    max = page.all('.arv-location').length
    count = 0
    arrivals = []
    while count < max
      text = page.all('.arv-location')[count].text
      arrival = text[/\(...\)/]
      unless arrival == nil
        arrival = arrival.gsub(/\W/, '')
        arrivals << arrival
      end
      count += 1
    end
    arrivals
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

  def get_uids
    uids = []
    page.all('h3').each { |h| uids << h['id'].gsub('airline-', '') if h['id'] && h['id'][/\d/] }
    uids
  end
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

  scraper = Scraper.new(origin, destination, date)

  scraper.visit_link(link)

  uids = scraper.get_uids
  binding.pry
  

  if scraper.non_stop
    puts origin + '-' + destination + date
    scraper.open
    sleep 2

    departures = scraper.departures
    arrivals = scraper.arrivals
    departure_times = scraper.departure_times
    arrival_times = scraper.arrival_times
    flight_nums = scraper.flight_nums
    carriers = scraper.carriers
    amounts = scraper.amounts

    flight_count = departures.count

    CSV.open(origin + '-' + destination + '-' + write_date + '-non-stop.csv', "wb") do |csv|
      count = 0
      while count < flight_count
        csv << [departures[count],
                arrivals[count],
                departure_times[count],
                arrival_times[count],
                flight_nums[count],
                carriers[count],
                amounts[count]]
        count += 1
      end
    end
  end
  
  scraper.one_stop
  scraper.open
  sleep 2

  flight_changes = scraper.no_change_of_planes
  num_flights = scraper.num_flights

  flight_changes.each_with_index do |change, i|
    num_flights[i / 2 - 2] -= 1 if change == "Stop"
  end

  num_flights

  departures = scraper.departures
  arrivals = scraper.arrivals
  departure_times = scraper.departure_times
  arrival_times = scraper.arrival_times
  flight_nums = scraper.flight_nums
  carriers = scraper.carriers
  amounts = scraper.amounts

  CSV.open(origin + '-' + destination + '-' + write_date + '-one-stop.csv', "wb") do |csv|
    num_flights.each do |num|
      count = 0
      if num == 2
        while count < num
          csv << [departures[count + 1],
                  arrivals[count + 1],
                  departure_times[count + 1],
                  arrival_times[count + 1],
                  flight_nums[count],
                  carriers[0],
                  amounts[0]]
          count += 1
        end
        if amounts.count != 0
          departures.shift(count + 1)
          arrivals.shift(count + 1)
          departure_times.shift(count + 1)
          arrival_times.shift(count + 1)
          flight_nums.shift(count)
          carriers.shift(1)
          amounts.shift(1)
        end
      else
        csv << [departures[count],
                arrivals[count],
                departure_times[count],
                arrival_times[count],
                flight_nums[count],
                carriers[count],
                amounts[count]]
        
        departures.shift(1)
        arrivals.shift(1)
        departure_times.shift(1)
        arrival_times.shift(1)
        flight_nums.shift(1)
        carriers.shift(1)
        amounts.shift(1)
      end
    end
  end
end







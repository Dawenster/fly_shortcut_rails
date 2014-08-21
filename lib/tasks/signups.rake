require 'csv'

task :change_signups_from_cities_to_airports => :environment do
  User.all.each do |user|
    user.cities.each do |city|
      airport = Airport.find_by_name(city.name)
      user.airports << airport unless user.airports.include?(airport)
    end
  end
end

task :export_signups => :environment do
  CSV.open("db/signups.csv", "wb") do |csv|
    User.all.each do |user|
      csv << [user.email, user.airports.map{ |airport| airport.name }.join(", "), user.created_at]
    end
  end
end
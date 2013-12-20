task :change_signups_from_cities_to_airports => :environment do
  User.all.each do |user|
    user.cities.each do |city|
      airport = Airport.find_by_name(city.name)
      user.airports << airport unless user.airports.include?(airport)
    end
  end
end
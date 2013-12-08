require 'csv'

task :create_airports => :environment do
  CSV.foreach('db/airports.csv') do |row|
  Airport.create( :city => row[0].strip,
                  :name => row[1].strip,
                  :code => row[2].strip,
                  :latitude => row[3].strip,
                  :longitude => row[4].strip,
                  :timezone => row[5].strip)
  end
end
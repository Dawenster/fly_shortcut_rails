class City < ActiveRecord::Base
  attr_accessible :name, :user_id, :latitude, :longitude, :address
  belongs_to :user
  geocoded_by :address
  after_validation :geocode
end
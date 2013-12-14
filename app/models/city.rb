class City < ActiveRecord::Base
  attr_accessible :name, :user_id
  belongs_to :user
  geocoded_by :address
  after_validation :geocode
end
class User < ActiveRecord::Base
  attr_accessible :email

  validates :email, :presence => true
  validates :email, :uniqueness => true
  validates :email, :format => { :with => /^[_a-z0-9-]+(\.[_a-z0-9-]+)*@[a-z0-9-]+(\.[a-z0-9-]+)*(\.[a-z]{2,4})$/ }
end
class User < ActiveRecord::Base
  attr_accessible :email
  has_many :cities

  has_and_belongs_to_many :airports

  validates :email, :presence => true
  # validates :email, :uniqueness => true
  validates :email, :format => { :with => /^[_a-z0-9-]+(\.[_a-z0-9-]+)*@[a-z0-9-]+(\.[a-z0-9-]+)*(\.[a-z]{2,4})$/ }

  def subscribe_to_mailchimp
    gb = Gibbon::API.new
    gb.lists.subscribe({
      :id => ENV["MAILCHIMP_SUBSCRIBERS_LIST_ID"],
      :email => {
        :email => self.email
      }, 
      :merge_vars => {
        "MMERGE4" => self.airports.map{ |airport| airport.name }.join(", "),
        "MMERGE5" => self.created_at
      },
      :double_optin => false,
      :update_existing => true
    })
  end
end
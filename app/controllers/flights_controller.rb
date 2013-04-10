class FlightsController < ApplicationController
  def index
    @flights = Flight.get_shortcuts
  end
end

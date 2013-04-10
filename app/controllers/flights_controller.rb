class FlightsController < ApplicationController
  def index
    @flights = Itinerary.get_shortcuts
  end
end

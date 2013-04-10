class FlightsController < ApplicationController
  def index
    @flights = Itinerary.get_shortcuts.uniq
  end
end

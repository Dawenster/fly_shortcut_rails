class FlightsController < ApplicationController
  def index
    @flights = Flight.get_shortcuts.uniq
  end
end

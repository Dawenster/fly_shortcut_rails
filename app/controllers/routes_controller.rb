class RoutesController < ApplicationController
  http_basic_authenticate_with :name => ENV['ADMIN_NAME'], :password => ENV['ADMIN_PASSWORD']

  def index
    @routes = Route.order("origin_airport_id ASC")
  end

  def new
    @route = Route.new
  end

  def create
    convert_airport_ids_to_code
    convert_price_to_integer
    @route = Route.new(params[:route])
    if @route.save
      flash[:success] = "#{Airport.find(@route.origin_airport_id).code} - #{Airport.find(@route.destination_airport_id).code} has been successfully created."
      redirect_to routes_path
    else
      flash.now[:warning] = "Gawd. Fill everything in correctly man."
      render "new"
    end
  end

  def edit
    @route = Route.find(params[:id])
  end

  def update
    convert_airport_ids_to_code
    convert_price_to_integer
    @route = Route.find(params[:id])
    @route.assign_attributes(params[:route])
    if @route.save
      flash[:success] = "#{Airport.find(@route.origin_airport_id).code} - #{Airport.find(@route.destination_airport_id).code} has been successfully updated."
      redirect_to routes_path
    else
      flash.now[:warning] = "Gawd. Fill everything in correctly man."
      render "edit"
    end
  end

  def destroy
    route = Route.find(params[:id]).destroy
    flash[:success] = "#{Airport.find(route.origin_airport_id).code} - #{Airport.find(route.destination_airport_id).code} has been deleted."
    redirect_to routes_path
  end

  private

  def convert_airport_ids_to_code
    params[:route][:origin_airport_id] = Airport.find_by_code(params[:route][:origin_airport_id]).id
    params[:route][:destination_airport_id] = Airport.find_by_code(params[:route][:destination_airport_id]).id
  end

  def convert_price_to_integer
    params[:route][:cheapest_price] = (params[:route][:cheapest_price].to_f * 100).to_i
  end
end
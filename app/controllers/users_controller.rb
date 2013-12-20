class UsersController < ApplicationController
  def create
    User.find_by_email(params[:email]) ? message = " is already on our list." : message = " successfully added."
    @user = User.find_or_initialize_by_email(params[:email])

    if @user.save
      if params[:city] == "(Desired departure airport)"
        render :json => { :email => @user.email, :message => message, :noCity => true }, :status => :created
      else
        airport = Airport.find_by_name(params[:city])
        @user && @user.airports.include?(airport) ? city_msg = " You already receive alerts for " : city_msg = " You will now #{@user.airports.any? ? 'also ' : ''}receive alerts for "
        @user.airports << airport
        render :json => { :email => @user.email, :message => message, :city => airport.name, :city_msg => city_msg }, :status => :created
      end
    else
      render :json => @user.errors.full_messages.join("<BR>"), :status => :unprocessable_entity
    end
  end
end
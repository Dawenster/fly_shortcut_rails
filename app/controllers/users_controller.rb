class UsersController < ApplicationController
  def create
    User.find_by_email(params[:email]) ? message = " is already on our list." : message = " successfully added."
    @user = User.find_or_initialize_by_email(params[:email])

    if @user.save
      if params[:city] == "(Desired departure airport)"
        render :json => { :email => @user.email, :message => message, :noCity => true }, :status => :created
      else
        City.where(:name => params[:city], :user_id => @user.id).any? ? city_msg = " You already receive alerts for " : city_msg = " You will now receive alerts for "
        city = City.create(:name => params[:city], :user_id => @user.id)
        @user.cities << city
        render :json => { :email => @user.email, :message => message, :city => city.name, :city_msg => city_msg }, :status => :created
      end
    else
      render :json => @user.errors.full_messages.join("<BR>"), :status => :unprocessable_entity
    end
  end
end
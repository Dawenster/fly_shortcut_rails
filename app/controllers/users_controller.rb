class UsersController < ApplicationController
  def create
    @user = User.new(params[:user] || { "email" => params[:email] })
    if @user.save
      render :json => { :email => @user.email }, :status => :created
    else
      render :json => @user.errors.full_messages.join("<BR>"), :status => :unprocessable_entity
    end
  end
end
class BlogsController < ApplicationController
  def index
    page = params[:page].to_i || 0
    client = Tumblr::Client.new
    tumblr_posts = client.posts("flyshortcut.tumblr.com", :filter => "text", :offset => page * 20)
    @posts = tumblr_posts["posts"]
    @user = User.new
    @airports = Airport.all.map { |airport| airport.name }.unshift("(Desired departure airport)")
  end

  def show
    client = Tumblr::Client.new
    @post = client.posts("flyshortcut.tumblr.com", :tag => params[:slug])["posts"][0]
    @user = User.new
    @airports = Airport.all.map { |airport| airport.name }.unshift("(Desired departure airport)")
  end
end
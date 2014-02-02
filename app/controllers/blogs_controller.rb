class BlogsController < ApplicationController
  def index
    page = params[:page].to_i || 0
    client = Tumblr::Client.new
    tumblr_posts = client.posts("dawenster.tumblr.com", :tag => "new", :offset => page * 20)
    @posts = tumblr_posts["posts"]
    @user = User.new
    @airports = Airport.all.map { |airport| airport.name }.unshift("(Desired departure airport)")
  end

  def show
    client = Tumblr::Client.new
    @post = client.posts("dawenster.tumblr.com", :tag => params[:slug])["posts"][0]
    @post["first_image"] = find_first_image(@post["body"])
    current_tag = find_tag_number(@post["tags"])
  end

  private

  def find_tag_number(arr)
    arr.select{ |e| e.to_i > 0 }.first.to_i
  end
end
class FriendsController < ApplicationController
  before_filter :logged_in?, :only => [:view]
  before_filter :guest?, :only => [:login]
  
  def login
  end

  def view
	@profile = @graph.get_object("me")
	
	friend_collection = @graph.get_connections('me', 'friends')
	@friends = []
	begin
	  @friends += friend_collection.map{|info| Person.new(info)}
    end while friend_collection = friend_collection.next_page
  end
  
  
  def logged_in?
	load_user
	redirect_to login_path unless @user_id
  end

  def guest?
    load_user
	redirect_to view_path if @user_id
  end
  
  def load_user
  	@app_id = "152063528195561"
	@app_secret = "7d656869e695a00d35bd73a135262091"
	@app_key = "ddee0c65f9dbd65396e57f018af27c15"
	callback_url = nil
	
	@oauth = Koala::Facebook::OAuth.new(@app_id, @app_secret, @callback_url)
	
	info = @oauth.get_user_info_from_cookies(cookies)
	
	if info
	  oauth_access_token = info['access_token']
	  @user_id = info['uid']
	  @graph = Koala::Facebook::GraphAPI.new(oauth_access_token)
	end
  end

end

class Person
  attr_accessor :name, :picture, :interests
  def initialize(graph, info)
	@id = info['id']
	@name = info['name']
	@picture = graph.get_picture(@id)
	
	#Do I need to loop over pages here as well?
	@interests = graph.get_connections(@id, 'interests').map {|obj| obj['name']}
	
  end
end
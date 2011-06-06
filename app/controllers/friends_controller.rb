class FriendsController < ApplicationController
  before_filter :logged_in?, :only => [:view]
  before_filter :guest?, :only => [:login]
  
  def login
  end

  def view
	@profile = @graph.get_object("me")
	
	puts "Loaded profile"
	friend_collection = @graph.get_connections('me', 'friends')

	person_names = []
	person_interests = Koala::Facebook::GraphAPI.batch do
      #begin
		friend_collection.each  do |info|
	      @graph.get_connections(info['id'], 'interests')
		  person_names << info['name']
		end
	  #while friend_collection = friend_collection.next_page
	end
	friend_info = person_names.zip(person_interests)
	@friends = friend_info.map {|info| Person.new(info) }
	
	@friends.delete_if {|friend| friend.interests.empty? }
	
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
	
	if Rails.env.production?
	  info = @oauth.get_user_info_from_cookies(cookies)
	
	  if info
	    oauth_access_token = info['access_token']
		@user_id = info['uid']
	  end
    else
	  oauth_access_token = "119908831367602|2.AQC650lY7FOHAMGY.3600.1307336400.1-1480650957|fnu7mGWFQCYRzs3L62eqN4XFRi8"
	  @user_id = "1480650957"
	end
	
	if @user_id
	  @graph = Koala::Facebook::GraphAPI.new(oauth_access_token)
	end
  end

end

class Person
  attr_accessor :name, :interests
  def initialize(info)
	@name = info[0]
	@interests = info[1].map {|interest| interest['name']}
  end
end
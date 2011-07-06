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
	person_ids = []
	person_interests = []
	
	
	buffer = []
  count = 0
	begin
	  friend_collection.each do |friend|
      count += 1
		  puts count
		  buffer.push(friend)
      if buffer.size == 20 #FB batch can only handle 20 items
     
        puts "Sending batch"
        person_interests += Koala::Facebook::GraphAPI.batch do
          buffer.each  do |info|
            @graph.get_connections(info['id'], 'interests')
            person_names << info['name']
            person_ids << info['id']
          end
        end
        
        buffer = []
      end
	  end
	end while friend_collection = friend_collection.next_page
	
	friend_info = person_names.zip(person_interests)
	id_info = person_ids.zip(person_interests)
  
  id_info.each do |info|
    id = info[0]
    interests = info[1].map {|interest| interest['name']}
    interests.each {|interest|
      row = UserInterest.find_by_user_id_and_interest_id(id, interest)
      UserInterest.create(:user_id => id, :interest_id => interest) unless row
    }
  end
  
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
	  oauth_access_token = "152063528195561|2.AQAgOiDI5fD6UsPh.3600.1307336400.1-1480650957|fDQTBcFq3p_sZ2OFF3jTJwY2WgU"
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
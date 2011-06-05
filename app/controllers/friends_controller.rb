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
  
  
  
  private
  
  def logged_in?
	load_user
	redirect_to 'friends/index' unless @user_id
  end

  def guest?
    load_user
	redirect_to 'friends/view' if @user_id
  end
  
  
  def fb_login(text, redirect, permissions)
    '<fb:login-button onlogin="window.location.href = &quot;' + redirect + '&quot;;" perms="' + permissions + '">' + text + '</fb:login-button>'
  end
  
  def load_user
  	@app_id = "152063528195561"
	@app_secret = "7d656869e695a00d35bd73a135262091"
	@app_key = "ddee0c65f9dbd65396e57f018af27c15"
	callback_url = nil
	
	@oauth = Koala::Facebook::OAuth.new(app_id, app_secret, callback_url)
	
	info = @oauth.get_user_info_from_cookies(cookies)
	
	if info
	  oauth_access_token = info['access_token']
	  @user_id = info['uid']
	  @graph = Koala::Facebook::GraphAPI.new(oauth_access_token)
	end
  end
  
  def fb_script
    "<div id='fb-root'></div>
          <script>
            window.fbAsyncInit = function() {
              FB.init({
                appId  : '#{@app_id}',
                status : true, // check login status
                cookie : true, // enable cookies to allow the server to access the session
                
                xfbml  : true  // parse XFBML
              });
              
            };

            (function() {
              var e = document.createElement('script'); e.async = true;
              e.src = document.location.protocol + '//connect.facebook.net/en_US/all.js';
              document.getElementById('fb-root').appendChild(e);
            }());
          </script>"
  end

end

class Person
  attr_accessor @name, @picture, @interests
  def initialize(graph, info)
	@id = info['id']
	@name = info['name']
	@picture = graph.get_picture(@id)
	
	#Do I need to loop over pages here as well?
	@interests = graph.get_connections(@id, 'interests').map {|obj| obj['name']}
	
  end
end
module FriendsHelper
  def fb_login(text, redirect, permissions)
    raw ('<fb:login-button onlogin="window.location.href = &quot;' + redirect + '&quot;;" perms="' + permissions + '">' + text + '</fb:login-button>')
  end
  
  def fb_script
    raw "<div id='fb-root'></div>
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

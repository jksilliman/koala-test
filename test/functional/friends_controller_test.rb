require 'test_helper'

class FriendsControllerTest < ActionController::TestCase
  test "should get login" do
    get :login
    assert_response :success
  end

  test "should get view" do
    get :view
    assert_response :success
  end

end

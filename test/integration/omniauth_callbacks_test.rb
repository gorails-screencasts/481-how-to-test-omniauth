require "test_helper"

class OmniauthCallbacksTest < ActionDispatch::IntegrationTest
  setup do
    OmniAuth.config.test_mode = true
    OmniAuth.config.add_mock(:developer, uid: "12345", info: { email: "bob@example.org" }, credentials: {token: "abcd"})
  end

  test "can sign up with OAuth" do
    assert_difference "User.count" do
      get "/users/auth/developer/callback"
    end

    user = User.last
    assert_equal "bob@example.org", user.email
    assert_equal "12345", user.services.last.uid
  end

  test "can login with OAuth" do
    user = User.create!(email: "bob@example.org", password: "password", password_confirmation: "password")
    user.services.create(provider: :developer, uid: "12345")

    get "/users/auth/developer/callback"

    get "/users/edit"
    assert_response :success
  end

  test "omniauth params" do
    assert_difference "User.count" do
      post "/users/auth/developer?name=Test+User"
      follow_redirect!
    end

    assert_equal "Test User", User.last.name
  end
end

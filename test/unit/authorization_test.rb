require 'require_relative' if RUBY_VERSION[0,3] == '1.8'
require_relative '../test_helper'

class AuthorizationTest < MiniTest::Unit::TestCase

  include TestHelper

  def test_find_from_hash
    u = Factory(:user)
    a = Factory(:authorization, :user => u)

    assert_equal a, Authorization.find_from_hash(auth_response(u.username, {:uid => a.uid}))
  end

  def test_create_from_hash
    u = Factory(:user)
    auth = auth_response(u.username)
    a = Authorization.create_from_hash(auth, "/", u)

    assert_equal auth["uid"], a.uid
    assert_equal auth["provider"], a.provider
    assert_equal auth["user_info"]["nickname"], a.nickname
    assert_equal auth['credentials']['token'], a.oauth_token
    assert_equal auth['credentials']['secret'], a.oauth_secret
  end

  def test_create_from_hash_no_uid
    a = Factory.build(:authorization, :uid => nil, :provider => "twitter")
    refute a.save, "can't be empty"
  end

  def test_create_from_hash_no_provider
    a = Factory.build(:authorization, :uid => 12345, :provider => nil)
    refute a.save, "can't be empty"
  end
end

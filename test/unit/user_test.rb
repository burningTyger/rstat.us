# encoding: UTF-8
require 'require_relative' if RUBY_VERSION[0,3] == '1.8'
require_relative '../test_helper'

class UserTest < MiniTest::Unit::TestCase

  include TestHelper

  def test_at_reply_filter
    u = Factory :user, :username => "steve"
    update = Factory(:update, :text => "@steve oh hai!")
    Factory(:update, :text => "just some other update")

    assert_equal 1, u.at_replies({}).length
    assert_equal update.id, u.at_replies({}).first.id
  end

  def test_hashtag_filter
    Factory :user, :username => "steve"
    update = Factory(:update, :text => "mother-effing #hashtags")
    Factory(:update, :text => "just some other update")

    assert_equal 1, Update.hashtag_search("hashtags", {}).length
    assert_equal update.id, Update.hashtag_search("hashtags", {}).first.id
  end

  def test_username_is_unique
    Factory(:user, :username => "steve")
    u = Factory.build(:user, :username => "steve")
    refute u.save
  end

  def test_username_is_unique_case_insensitive
    Factory(:user, :username => "steve")
    u = Factory.build(:user, :username => "Steve")
    refute u.save
  end

  def test_username_is_too_long
    u = Factory.build :user, :username => "burningTyger_will_fail_with_this_username"
    refute u.save
  end

  def test_user_has_twitter
    u = Factory.create(:user)
    a = Factory.create(:authorization, :user => u)
    assert u.twitter?
  end

  def test_user_returns_twitter
    u = Factory.create(:user)
    a = Factory.create(:authorization, :user => u)
    assert_equal a, u.twitter
  end

  def test_user_has_facebook
    u = Factory.create(:user)
    a = Factory.create(:authorization, :user => u, :provider => "facebook")
    assert u.facebook?
  end

  def test_user_returns_facebook
    u = Factory.create(:user)
    a = Factory.create(:authorization, :user => u, :provider => "facebook")
    assert_equal a, u.facebook
  end

  def test_set_reset_password_token
    u = Factory.create(:user)
    assert_nil u.perishable_token
    assert_nil u.password_reset_sent
    u.set_password_reset_token
    refute u.perishable_token.nil?
    refute u.password_reset_sent.nil?
  end

  def test_reset_password
    u = Factory.build(:user)
    u.password = "test_password"
    u.save
    prev_pass = u.hashed_password
    u.reset_password("password")
    assert u.hashed_password != prev_pass
  end

  def test_no_special_chars_in_usernames
    ["something@something.com", "another'quirk", ".boundary_case.", "another..case", "another/random\\test", "yet]another", ".Ὁμηρος", "I have spaces"].each do |i|
      u = Factory.build :user, :username => i
      refute u.save, "contains restricted characters."
    end
    ["Ὁμηρος"].each do |i|
      u = Factory.build :user, :username => i
      assert u.save, "characters being restricted unintentionally."
    end
  end

  def test_username_cant_be_empty
    u = Factory.build :user, :username => ""
    refute u.save, "blank username"
  end

  def test_username_is_ok
    u = Factory.build :user, :username => "justauser"
    assert u.save
  end
  
  def test_username_cant_be_nil
    u = Factory.build :user, :username => nil
    refute u.save, "nil username"
  end

  def test_reply_regexp
    u = Factory.create(:user, :username => "hello.there")
    u1 = Factory.create(:user, :username => "helloothere")
    update = Update.create(:text => "@hello.there how _you_ doin'?")

    assert_equal 1, u.at_replies({}).length
    assert_equal 0, u1.at_replies({}).length
  end

end

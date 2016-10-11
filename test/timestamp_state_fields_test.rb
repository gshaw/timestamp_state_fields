require 'test_helper'

class TimestampStateFieldsTest < ActiveSupport::TestCase
  def build_subscribed_user(name: "Bob")
    User.new(name: name, subscribed_at: Time.current)
  end

  def build_not_subscribed_user(name: "Bob")
    User.new(name: name, subscribed_at: nil)
  end

  def test_subscribed?
    user = build_not_subscribed_user
    refute user.subscribed?
    assert user.not_subscribed?
    user.subscribed_at = Time.current
    assert user.subscribed?
    refute user.not_subscribed?
  end

  def test_mark_as_subscribed
    user = build_not_subscribed_user
    refute user.subscribed?
    user.mark_as_subscribed
    assert user.subscribed?
  end

  def test_mark_as_not_subscribed
    user = build_subscribed_user
    assert user.subscribed?
    user.mark_as_not_subscribed
    refute user.subscribed?
  end

  def test_is_subscribed
    user = build_subscribed_user
    assert user.subscribed?
    assert user.is_subscribed
  end

  def test_is_subscribed_assignment
    user = build_not_subscribed_user
    refute user.subscribed?
    user.is_subscribed = "1"
    assert user.subscribed?
    user.is_subscribed = "0"
    assert user.not_subscribed?
  end

  def test_subscribed_scope
    build_subscribed_user.save!
    build_not_subscribed_user.save!
    users = User.subscribed
    assert users.count > 0
    users.each { |u| assert u.subscribed? }
  end

  def test_not_subscribed_scope
    build_subscribed_user.save!
    build_not_subscribed_user.save!
    users = User.not_subscribed
    assert users.count > 0
    users.each { |u| refute u.subscribed? }
  end
end

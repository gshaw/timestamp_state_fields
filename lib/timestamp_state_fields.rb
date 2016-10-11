module TimestampStateFields
  extend ActiveSupport::Concern

  module ClassMethods
    # Implements ActiveRecord state fields based on timestamp columns.
    #
    # Requires a column in the model to have :`state`_at
    #
    # Example:
    #
    #   class User < ActiveRecord::Base
    #     include TimestampStateFields
    #     timestamp_state_fields :subscribed_at, :verified_at
    #   end
    #
    #   u = User.new
    #   u.subscribed?     # => false
    #   u.mark_as_subscribed
    #   u.subscribed_at   # => "2015-11-15 22:51:13 -0800"
    #   u.subscribed?     # => true
    #   u.is_subscribed   # => true
    #
    #   u.is_verified = true # Useful for form checkbox fields
    #   u.is_verified = true # Keeps oldest time
    #   u.mark_as_not_verified
    #
    #   User.subscribed.count               # Number of subscribed users
    #   User.subscribed.not_verified.count  # Number of unsubscribed users that are not verified
    #
    def timestamp_state_fields(*field_names)
      field_names.map(&:to_s).each do |field_name|
        raise ArgumentError.new("Timestamp name should end with `_at`") unless field_name.end_with?("_at")
        state_name = field_name.sub(/_at\z/, "")

        define_singleton_method(:"#{state_name}") do
          where.not(field_name => nil)
        end

        define_singleton_method(:"not_#{state_name}") do
          where(field_name => nil)
        end

        define_method(:"#{state_name}?") do
          read_attribute(field_name).present?
        end

        define_method(:"not_#{state_name}?") do
          !send(:"#{state_name}?")
        end

        define_method(:"mark_as_#{state_name}") do
          send(:"is_#{state_name}=", "1")
        end

        define_method(:"mark_as_not_#{state_name}") do
          send(:"is_#{state_name}=", "0")
        end

        define_method(:"is_#{state_name}") do
          send(:"#{state_name}?")
        end

        define_method(:"is_#{state_name}=") do |value|
          field_value = value.to_i.nonzero? ? (read_attribute(state_name) || Time.current) : nil
          write_attribute(field_name, field_value)
        end
      end
    end
  end
end

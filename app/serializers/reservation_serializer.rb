# frozen_string_literal: true

# The ReservationSerializer class is responsible for defining how reservation data
# is serialized into JSON format. It specifies the attributes to include in the
# serialized output, enhancing the representation of reservation details.
#
# @!attribute [r] id
#   @return [Integer] the unique identifier for the reservation
# @!attribute [r] user_id
#   @return [Integer] the ID of the user who made the reservation
# @!attribute [r] room_id
#   @return [Integer] the ID of the room associated with the reservation
# @!attribute [r] check_in
#   @return [Date] the check-in date for the reservation
# @!attribute [r] check_out
#   @return [Date] the check-out date for the reservation
#
class ReservationSerializer < ActiveModel::Serializer
  # Specifies the attributes to be serialized in the output.
  #
  # @return [Array<Symbol>] The list of attributes to include in the serialized output.
  attributes :full_name, :avatar, :hotel_name, :room_number, :check_in, :check_out, :user_preferences

  # Returns the full name of the user who made the reservation.
  #
  # @return [String] The full name of the user.
  def full_name
    "#{object.user.first_name} #{object.user.last_name}"
  end

  # Returns the URL of the user's avatar image.
  #
  # @return [String, nil] The URL of the user's avatar image if attached, otherwise nil.
  def avatar
    return unless object.user.image.attached?

    Rails.application.routes.url_helpers.rails_blob_url(object.user.image, only_path: true)
  end

  # Returns the name of the hotel associated with the reservation.
  #
  # @return [String] The name of the hotel.
  def hotel_name
    object.room.hotel.name
  end

  # Returns the room number associated with the reservation.
  #
  # @return [Integer] The number of the room.
  def room_number
    object.room.number
  end

  # Returns the preferences of the user who made the reservation.
  #
  # @return [String, nil] The user preferences or nil if not set.
  def user_preferences
    object.user.preferences
  end
end

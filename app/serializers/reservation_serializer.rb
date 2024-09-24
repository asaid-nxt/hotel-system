# frozen_string_literal: true

# The ReservationSerializer class is responsible for defining how reservation data
# is serialized into JSON format. It specifies the attributes to include in the
# serialized output.
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
  # Specifies the attributes to be serialized.
  attributes :full_name, :avatar, :hotel_name, :room_number, :check_in, :check_out, :user_preferences

  def full_name
    "#{object.user.first_name} #{object.user.last_name}"
  end

  def avatar
    return unless object.user.image.attached?

    Rails.application.routes.url_helpers.rails_blob_url(object.user.image, only_path: true)
  end

  def hotel_name
    object.room.hotel.name
  end

  def room_number
    object.room.number
  end

  def user_preferences
    object.user.preferences
  end
end

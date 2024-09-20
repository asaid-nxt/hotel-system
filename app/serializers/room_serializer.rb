# frozen_string_literal: true

# The RoomSerializer class defines how room data is serialized into JSON format.
# It specifies the attributes to include in the serialized output.
#
# @!attribute [r] room_number
#   @return [String] the room number (mapped from the Room model's `number` attribute)
#
# @!attribute [r] hotel_id
#   @return [Integer] the ID of the hotel where the room is located
#
# @!attribute [r] capacity
#   @return [Integer] the maximum capacity of the room
#
# @!attribute [r] amenities
#   @return [String] the amenities available in the room
#
class RoomSerializer < ActiveModel::Serializer
  # Specifies the attributes to be serialized.
  attributes :room_number, :hotel_id, :capacity, :amenities

  # Maps the room number from the Room model's `number` attribute.
  #
  # @return [String] the room number
  def room_number
    object.number
  end
end

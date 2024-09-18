# frozen_string_literal: true

# The RoomSerializer class defines how room data is serialized into JSON format.
# It specifies the attributes to include in the serialized output.
#
# @!attribute [r] number
#   @return [Integer] the room number
#
# @!attribute [r] hotel_id
#   @return [Integer] the ID of the hotel where the room is located
#
# @!attribute [r] capacity
#   @return [Integer] the maximum capacity of the room
#
# @!attribute [r] amenities
#   @return [Array<String>] the amenities available in the room
#
class RoomSerializer < ActiveModel::Serializer
  # Specifies the attributes to be serialized.
  attributes :number, :hotel_id, :capacity, :amenities
end

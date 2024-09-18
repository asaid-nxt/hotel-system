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
  attributes :id, :user_id, :room_id, :check_in, :check_out
end

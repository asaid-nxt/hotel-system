class ReservationSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :room_id, :check_in, :check_out
end

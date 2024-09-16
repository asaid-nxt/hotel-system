class RoomSerializer < ActiveModel::Serializer
  attributes :number, :hotel_id, :capacity, :amenities
end

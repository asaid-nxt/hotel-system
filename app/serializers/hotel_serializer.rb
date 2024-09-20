# frozen_string_literal: true

class HotelSerializer < ActiveModel::Serializer
  attributes :id, :name, :location, :amenities
end

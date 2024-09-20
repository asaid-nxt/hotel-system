# frozen_string_literal: true

# HotelSerializer is responsible for serializing Hotel objects into JSON format.
#
# @!attribute [r] id
#   @return [Integer] the unique ID of the hotel
#
# @!attribute [r] name
#   @return [String] the name of the hotel
#
# @!attribute [r] location
#   @return [String] the location of the hotel
#
# @!attribute [r] amenities
#   @return [String] the list of amenities available at the hotel
#
class HotelSerializer < ActiveModel::Serializer
  attributes :id, :name, :location, :amenities
end

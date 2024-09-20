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
# @!attribute [r] image_url
#   @return [String, nil] the URL of the hotel's image, or nil if not attached
#
class HotelSerializer < ActiveModel::Serializer
  attributes :id, :name, :location, :amenities, :image_url

  # Returns the URL for the hotel's attached image.
  #
  # @return [String, nil] The URL of the attached image or nil if no image is attached.
  def image_url
    Rails.application.routes.url_helpers.rails_blob_url(object.image, only_path: true) if object.image.attached?
  end
end

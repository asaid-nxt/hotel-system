# frozen_string_literal: true

# Hotel model that represents a hotel entity.
# A hotel can have many rooms associated with it and an attached image.
#
# @!attribute [rw] name
#   The name of the hotel.
#   @return [String]
#
# @!attribute [rw] location
#   The location of the hotel.
#   @return [String]
#
# @!attribute [rw] image
#   The image attached to the hotel.
#   @return [ActiveStorage::Attached::One]
#
class Hotel < ApplicationRecord
  # A hotel has many rooms. If the hotel is destroyed, its associated rooms
  # will also be destroyed.
  #
  # @return [ActiveRecord::Associations::CollectionProxy<Room>]
  has_many :rooms, dependent: :destroy

  # A hotel can have an image attached.
  #
  # @return [ActiveStorage::Attached::One]
  has_one_attached :image

  # Validates the presence of the hotel's name and location.
  # Ensures that these attributes must be present for a hotel to be valid.
  #
  # @note Does not need a return type for validation
  validates :name, presence: true, uniqueness: true
  validates :location, presence: true
end

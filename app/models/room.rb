# frozen_string_literal: true

# Room model that represents a room in a hotel.
# A room belongs to a specific hotel and can have many reservations.
#
# @!attribute [rw] number
#   The room number in the hotel.
#   @return [Integer]
#
# @!attribute [rw] capacity
#   The capacity of the room, indicating how many people can stay in it.
#   @return [Integer]
#
# @!attribute [r] hotel
#   The hotel to which this room belongs.
#   @return [Hotel]
#
# @!attribute [r] reservations
#   The reservations made for this room.
#   @return [Array<Reservation>]
#
class Room < ApplicationRecord
  belongs_to :hotel
  has_many :reservations, dependent: :destroy

  # Validates the presence of the room number and capacity.
  # Validates that the capacity must be a positive integer.
  validates :number, :capacity, presence: true
  validates :capacity, numericality: { greater_than: 0 }

  # Scope to find rooms that are available in a given hotel within a date range.
  #
  # @param hotel_id [Integer] The ID of the hotel to search in.
  # @param check_in [Date] The start date for room availability.
  # @param check_out [Date] The end date for room availability.
  # @return [ActiveRecord::Relation] The available rooms.
  scope :available, lambda { |hotel_id, check_in, check_out|
    where(hotel_id:)
      .where.not(id: Reservation.where('check_in < ? AND check_out > ?', check_out, check_in).select(:room_id))
  }

  # Checks if the room is available for the given date range.
  #
  # @param check_in [Date] The start date to check availability.
  # @param check_out [Date] The end date to check availability.
  # @return [Boolean] True if the room is available, false otherwise.
  def available?(check_in, check_out)
    !reservations.where('check_in < ? AND check_out > ?', check_out, check_in).exists?
  end
end

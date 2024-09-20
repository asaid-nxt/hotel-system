# Reservation model represents a booking of a room by a user with check-in and check-out dates.
#
# @!attribute [rw] check_in
#   @return [Date] the date the reservation starts
#
# @!attribute [rw] check_out
#   @return [Date] the date the reservation ends
#
# @!attribute [r] user
#   @return [User] the user who made the reservation
#
# @!attribute [r] room
#   @return [Room] the room being reserved
#
# @!scope class
#   Scopes to filter reservations by their status relative to today's date.
#
# @!method self.past
#   @return [ActiveRecord::Relation] all reservations with a check-out date before today
#
# @!method self.current
#   @return [ActiveRecord::Relation] all reservations with a check-in date in the past or today, and a check-out date in the future or today
#
# @!method self.future
#   @return [ActiveRecord::Relation] all reservations with a check-in date in the future
#
# @!method check_dates
#   Validates that the check-out date is after the check-in date.
#
class Reservation < ApplicationRecord
  belongs_to :user
  belongs_to :room

  validates :check_in, :check_out, presence: true
  validate :check_dates

  scope :past, -> { where('check_out < ?', Date.today.to_s) }
  scope :current, -> { where('check_in <= ? AND check_out >= ?', Date.today.to_s, Date.today.to_s) }
  scope :future, -> { where('check_in > ?', Date.today.to_s) }

  private

  # Validates that the check-out date is after the check-in date.
  #
  # @return [void]
  def check_dates
    return if check_in.nil? || check_out.nil?

    errors.add(:check_out, 'must be after check-in') if check_in >= check_out
  end
end

class Reservation < ApplicationRecord
  belongs_to :user
  belongs_to :room

  validates :check_in, :check_out, presence: true
  validate :check_dates

  private

  def check_dates
    return if check_in.nil? || check_out.nil?

    errors.add(:check_out, 'must be after check-in') if check_in >= check_out
  end
end

class Reservation < ApplicationRecord
  belongs_to :user
  belongs_to :room

  validates :check_in, :check_out, presence: true
  validate :check_dates

  scope :past, -> { where('check_out < ?', Date.today.to_s) }
  scope :current, -> { where('check_in <= ? AND check_out >= ?', Date.today.to_s, Date.today.to_s) }
  scope :future, -> { where('check_in > ?', Date.today.to_s) }

  private

  def check_dates
    return if check_in.nil? || check_out.nil?

    errors.add(:check_out, 'must be after check-in') if check_in >= check_out
  end
end

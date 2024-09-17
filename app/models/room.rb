class Room < ApplicationRecord
  belongs_to :hotel
  has_many :reservations, dependent: :destroy

  validates :number, :capacity, presence: true
  validates :capacity, numericality: { greater_than: 0 }

  scope :available, lambda { |hotel_id, check_in, check_out|
    where(hotel_id:)
      .where.not(id: Reservation.where('check_in < ? AND check_out > ?', check_out, check_in).select(:room_id))
  }

  def available?(check_in, check_out)
    !reservations.where('check_in < ? AND check_out > ?', check_out, check_in).exists?
  end
end

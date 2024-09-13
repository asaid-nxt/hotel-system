class Room < ApplicationRecord
  belongs_to :hotel
  has_many :reservations, dependent: :destroy

  validates :number, :capacity, presence: true
  validates :capacity, numericality: { greater_than: 0 }
end

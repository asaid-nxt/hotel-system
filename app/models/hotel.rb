# frozen_string_literal: true

class Hotel < ApplicationRecord
  has_many :rooms, dependent: :destroy

  validates :name, :location, presence: true
end

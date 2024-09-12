# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password

  enum role: { user: 0, admin: 1 }

  validates :username, presence: true, uniqueness: true
  validates :password, presence: true, length: { minimum: 6 }
end

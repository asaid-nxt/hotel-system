# frozen_string_literal: true

# The User class represents a user in the system and handles authentication
# and role-based access. Users can make reservations and have a unique username
# and password for authentication.
#
# @!attribute [rw] username
#   @return [String] the username of the user, which must be unique
#
# @!attribute [rw] password
#   @return [String] the user's password, securely stored and authenticated
#
# @!attribute [rw] role
#   @return [Symbol] the role of the user, either :user or :admin
#
# @!method has_secure_password
#   Adds methods to set and authenticate against a BCrypt password.
#   This method is added by `has_secure_password`.
#
# @!method reservations
#   Returns the reservations associated with this user.
#   @return [ActiveRecord::Associations::CollectionProxy] a collection of the user's reservations
#
# @!attribute [r] id
#   @return [Integer] the unique identifier for the user
#
# Validations:
# - Username must be present and unique.
# - Password must be present and have a minimum length of 6 characters.
#
# @!method generate_jwt
#   Generates a JSON Web Token (JWT) for the user. This token can be used for user authentication.
#   @return [String] the generated JWT token
#
class User < ApplicationRecord
  # Adds methods to set and authenticate a password securely.
  has_secure_password

  # Establishes a one-to-many relationship with reservations.
  has_many :reservations, dependent: :destroy

  # Defines the possible roles a user can have.
  enum role: { user: 0, admin: 1 }

  # Validations
  validates :username, presence: true, uniqueness: true
  validates :password, presence: true, length: { minimum: 6 }

  # A User can have an image attached.
  #
  # @return [ActiveStorage::Attached::One]
  has_one_attached :image

  # Generates a JSON Web Token (JWT) for the user.
  # This token can be used for user authentication.
  #
  # @return [String] the generated JWT token
  def generate_jwt
    JwtService.encode({ user_id: id })
  end
end

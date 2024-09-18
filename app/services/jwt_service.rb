# frozen_string_literal: true

# JwtService provides methods to encode and decode JSON Web Tokens (JWTs).
#
# This service handles the creation and parsing of JWT tokens used for authentication.
class JwtService
  # The secret key used for encoding and decoding JWT tokens.
  SECRET_KEY = Rails.application.credentials.secret_key_base.to_s

  # Encodes a payload into a JWT token.
  #
  # @param payload [Hash] The payload to be encoded into the JWT.
  # @return [String] The encoded JWT token.
  #
  # @example
  #   JwtService.encode({ user_id: 1 })
  #   # => "token"
  def self.encode(payload)
    JWT.encode(payload, SECRET_KEY)
  end

  # Decodes a JWT token and returns the payload.
  #
  # @param token [String] The JWT token to be decoded.
  # @return [HashWithIndifferentAccess, nil] The decoded payload as a HashWithIndifferentAccess,
  #   or nil if decoding fails.
  #
  # @example
  #   JwtService.decode("token")
  #   # => { "user_id" => 1 }
  #
  # @raise [JWT::DecodeError] If the token is invalid or cannot be decoded.
  def self.decode(token)
    decoded = JWT.decode(token, SECRET_KEY)[0]
    HashWithIndifferentAccess.new(decoded)
  rescue JWT::DecodeError
    nil
  end
end

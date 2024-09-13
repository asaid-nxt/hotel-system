# frozen_string_literal: true

# Serializes the User model into a JSON response.
#
# This serializer is responsible for specifying the attributes
# of the User model that will be exposed in the API response.
class UserSerializer < ActiveModel::Serializer
  # The attributes of the User model to be included in the serialized JSON.
  #
  # @return [Array<Symbol>] An array of symbols representing the attributes of the user.
  attributes :id, :username, :role
end

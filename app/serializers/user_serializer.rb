# frozen_string_literal: true

# Serializes the User model into a JSON response.
#
# This serializer is responsible for specifying the attributes
# of the User model that will be exposed in the API response.
#
# @!attribute [r] avatar_url
#   @return [String, nil] the URL of the User's avatar, or nil if not attached
#
class UserSerializer < ActiveModel::Serializer
  # The attributes of the User model to be included in the serialized JSON.
  #
  # @return [Array<Symbol>] An array of symbols representing the attributes of the user.
  attributes :username, :full_name, :preferences, :image_url

  # Returns the URL for the User's attached avatar.
  #
  # @return [String, nil] The URL of the attached avatar or nil if no image is attached.
  def image_url
    Rails.application.routes.url_helpers.rails_blob_url(object.image, only_path: true) if object.image.attached?
  end

  # Returns the full name of the User by concatenating first and last names.
  #
  # @return [String] The full name of the User.
  def full_name
    "#{object.first_name} #{object.last_name}"
  end
end

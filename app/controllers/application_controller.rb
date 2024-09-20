# frozen_string_literal: true

# Base controller for the API, providing common functionality to all controllers.
#
# This controller provides authentication methods that are used by other controllers
# to verify users and ensure only authenticated or authorized users can access certain
# endpoints.
class ApplicationController < ActionController::API
  private

  # @!attribute [rw] current_user
  #   @return [User, nil] the currently authenticated user, or `nil` if no user is authenticated.
  attr_accessor :current_user

  # Authenticates the user based on the Authorization header token.
  #
  # This method extracts the JWT token from the `Authorization` header, decodes it,
  # and sets the `current_user` based on the decoded user ID. If the token is invalid or
  # missing, it renders a JSON response with an unauthorized error.
  #
  # @return [void] Sets `current_user` or renders an unauthorized response.
  def authenticate_user!
    token = request.headers['Authorization']&.split(' ')&.last
    decoded_token = JwtService.decode(token)

    return render json: { error: 'Unauthorized' }, status: :unauthorized unless decoded_token

    self.current_user = User.find(decoded_token[:user_id])
  end

  # Authenticates the admin user.
  #
  # This method first calls {#authenticate_user!} to ensure a user is authenticated.
  # If the authenticated user is not an admin, it renders an unauthorized error response.
  #
  # @return [void] Allows request to proceed if the user is an admin, or renders an unauthorized response.
  def authenticate_admin!
    authenticate_user!
    return if performed? # Check if response has already been sent

    render json: { error: 'Unauthorized' }, status: :unauthorized unless current_user&.admin?
  end
end

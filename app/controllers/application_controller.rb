# frozen_string_literal: true

# Base controller for the API, providing common functionality to all controllers.
class ApplicationController < ActionController::API
  private

  attr_accessor :current_user

  def authenticate_user!
    token = request.headers['Authorization']&.split(' ')&.last
    decoded_token = JwtService.decode(token)

    render json: { error: 'Unauthorized' }, status: :unauthorized and return unless decoded_token

    self.current_user = User.find(decoded_token[:user_id])
  end

  def authenticate_admin!
    authenticate_user!
    return if performed?

    render json: { error: 'Unauthorized' }, status: :unauthorized unless current_user&.admin?
  end
end

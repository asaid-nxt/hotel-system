# frozen_string_literal: true

class ApplicationController < ActionController::API
  private

  attr_accessor :current_user

  def authenticate_user!
    token = request.headers['Authorization']
    decoded_token = JwtService.decode(token)

    if decoded_token
      self.current_user = User.find(decoded_token[:user_id])
    else
      render json: { error: 'Unauthorized' }, status: :unauthorized
    end
  end

  def authenticate_admin!
    authenticate_user!
    return if performed?

    render json: { error: 'Unauthorized' }, status: :unauthorized unless current_user&.admin?
  end
end

# frozen_string_literal: true

class ApplicationController < ActionController::API
  before_action :authenticate_request

  private

  attr_reader :current_user

  def authenticate_request
    token = request.headers['Authorization']
    decoded_token = JwtService.decode(token)

    if decoded_token
      @current_user = User.find(decoded_token[:user_id])
    else
      render json: { error: 'Unauthorized' }, status: :unauthorized
    end
  end

  def authenticate_admin!
    render json: { error: 'Unauthorized' }, status: :unauthorized unless current_user&.admin?
  end
end

# frozen_string_literal: true

module Api
  module V1
    class SessionsController < ApplicationController
      def create
        user = User.find_by(username: params[:username])

        if user&.authenticate(params[:password])
          token = user.generate_jwt
          render json: { token: }, status: :ok
        else
          render json: { error: 'Invalid username or password' }, status: :unauthorized
        end
      end
    end
  end
end

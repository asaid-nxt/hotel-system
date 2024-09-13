# frozen_string_literal: true

module Api
  module V1
    # SessionsController is responsible for user login
    # and generating a JWT token if the user credentials are valid.
    #
    # @api public
    class SessionsController < ApplicationController
      # Logs in the user by authenticating their username and password.
      # If authentication is successful, a JWT token is returned.
      #
      # @return [JSON] A JSON response containing the JWT token if authentication is successful,
      #   or an error message if the credentials are invalid.
      #
      # @example Successful authentication
      #   POST /api/v1/sessions
      #   Params: { username: "example", password: "password" }
      #   Response: { token: "jwt_token" }
      #
      # @example Failed authentication
      #   POST /api/v1/sessions
      #   Params: { username: "example", password: "wrong_password" }
      #   Response: { error: "Invalid username or password" }
      #
      # @raise [ActiveRecord::RecordNotFound] if the user is not found.
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

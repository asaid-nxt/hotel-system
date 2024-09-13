# frozen_string_literal: true

module Api
  module V1
    # UsersController handles user registration and JWT generation.
    #
    # @api public
    class UsersController < ApplicationController
      # Registers a new user and returns a JWT token upon successful creation.
      #
      # @return [JSON] A JSON response containing the JWT token and user information
      #   if the user is successfully created, or an error message if the user creation fails.
      #
      # @example Successful user creation
      #   POST /api/v1/users
      #   Params: { username: "new_user", password: "password", password_confirmation: "password", role: "user" }
      #   Response: { token: "jwt_token", user: { username: "new_user", role: "user" } }
      #
      # @example Failed user creation
      #   POST /api/v1/users
      #   Params: { username: "new_user", password: "password", password_confirmation: "wrong_password", role: "user" }
      #   Response: { errors: ["Password confirmation doesn't match Password"] }
      #
      # @raise [ActiveRecord::RecordInvalid] if user fails validation and is not saved.
      def create
        user = User.new(user_params)

        if user.save
          token = user.generate_jwt
          render json: { token:, user: UserSerializer.new(user) }, status: :created
        else
          render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      # Strong parameters for creating a user.
      #
      # @return [ActionController::Parameters] Permitted user parameters including username, password,
      #   password_confirmation, and role.
      #
      # @example
      #   { user: { username: "example", password: "password", password_confirmation: "password", role: "user" } }
      def user_params
        params.require(:user).permit(:username, :password, :password_confirmation, :role)
      end
    end
  end
end

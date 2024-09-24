# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Login', type: :request do # rubocop:disable Metrics/BlockLength
  path '/api/v1/login' do # rubocop:disable Metrics/BlockLength
    post 'Login a user' do # rubocop:disable Metrics/BlockLength
      tags 'Authentication'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :login_params, in: :body, schema: {
        type: :object,
        properties: {
          username: { type: :string, example: 'test' },
          password: { type: :string, example: 'password' }
        },
        required: %w[username password]
      }

      response '200', 'Login successful' do
        let(:user) { create(:user) }
        let(:login_params) { { username: user.username, password: user.password } }
        schema type: :object, properties: {
          token: { type: :string, example: '{token}' }
        }

        run_test!
      end

      response '401', 'Invalid username or password' do
        let(:login_params) { { username: 'wronguser', password: 'wrongpassword' } }
        schema type: :object, properties: {
          error: { type: :string, example: 'Invalid username or password' }
        }

        run_test!
      end
    end
  end
end

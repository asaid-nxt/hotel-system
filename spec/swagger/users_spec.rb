# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Users API', type: :request do # rubocop:disable Metrics/BlockLength
  path '/api/v1/signup' do # rubocop:disable Metrics/BlockLength
    post 'Creates a new user' do # rubocop:disable Metrics/BlockLength
      tags 'Users'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              username: { type: :string, example: 'test' },
              password: { type: :string, example: 'password' },
              password_confirmation: { type: :string, example: 'password' },
              role: { type: :integer, example: 0 }
            },
            required: %w[username password password_confirmation]
          }
        }
      }

      response '201', 'User created' do
        let(:user) { { user: attributes_for(:user) } }
        run_test!

        schema type: :object,
               properties: {
                 token: { type: :string, example: '{token}' },
                 user: {
                   type: :object,
                   properties: {
                     id: { type: :integer, example: 31 },
                     username: { type: :string, example: 'test2' },
                     role: { type: :string, example: 'user' }
                   }
                 }
               }
      end

      response '422', 'Invalid request' do
        let(:user) { { user: { username: '', password: 'password123', password_confirmation: 'password123' } } }
        run_test!
        example 'application/json', 'Invalid request', {
          error: 'Validation failed: Username can\'t be blank'
        }
      end
    end
  end
end

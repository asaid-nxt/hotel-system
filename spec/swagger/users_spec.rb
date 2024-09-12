# spec/integration/users_spec.rb

require 'swagger_helper'

RSpec.describe 'Users API', type: :request do
  path '/api/v1/signup' do
    post 'Creates a new user' do
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
      end

      response '422', 'Invalid request' do
        let(:user) { { user: { username: '', password: 'password123', password_confirmation: 'password123' } } }
        run_test!
      end
    end
  end
end

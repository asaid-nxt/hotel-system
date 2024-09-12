require 'swagger_helper'

RSpec.describe 'Login', type: :request do
  path '/api/v1/login' do
    post 'Login a user' do
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
          token: { type: :string }
        }

        run_test!
      end

      response '401', 'Invalid username or password' do
        let(:login_params) { { username: 'wronguser', password: 'wrongpassword' } }
        schema type: :object, properties: {
          error: { type: :string }
        }

        run_test!
      end
    end
  end
end

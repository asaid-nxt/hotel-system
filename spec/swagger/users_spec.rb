# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Users API', type: :request do # rubocop:disable Metrics/BlockLength
  let(:valid_attributes) do
    {
      user: {
        username: 'test',
        password: 'password',
        password_confirmation: 'password',
        first_name: 'Harry',
        last_name: 'Kane',
        preferences: 'Pool, Gym',
        role: 0,
        image: fixture_file_upload(Rails.root.join('spec', 'fixtures', 'files', 'avatar.jpg'), 'image/jpg')
      }
    }
  end
  path '/api/v1/signup' do # rubocop:disable Metrics/BlockLength
    post 'Creates a new user' do # rubocop:disable Metrics/BlockLength
      tags 'Users'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :attributes, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              username: { type: :string, example: 'test' },
              password: { type: :string, example: 'password' },
              password_confirmation: { type: :string, example: 'password' },
              first_name: { type: :string, example: 'Harry' },
              last_name: { type: :string, example: 'Kane' },
              preferences: { type: :text, example: 'Gym' },
              role: { type: :integer, example: 0 },
              image: { type: :string, format: :binary, example: '' }
            },
            required: %w[username password]
          }
        }
      }

      response '201', 'User created' do
        let(:attributes) { valid_attributes }
        run_test!

        example 'application/json', :success_example, {
          token: '{token}',
          user: {
            username: 'test',
            full_name: 'Harry Kane',
            preferences: 'Gym, Pool',
            image_url: '/path/to/image.png'
          }
        }
      end

      response '422', 'Invalid request' do
        let(:attributes) { { user: { username: '', password: 'password123', password_confirmation: 'password123' } } }
        run_test!
        example 'application/json', 'Invalid request', {
          error: 'Validation failed: Username can\'t be blank'
        }
      end
    end
  end
end

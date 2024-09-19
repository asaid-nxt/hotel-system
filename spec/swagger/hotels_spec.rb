# spec/integration/api/v1/hotels_spec.rb

require 'swagger_helper'

RSpec.describe 'api/v1/hotels', type: :request do # rubocop:disable Metrics/BlockLength
  let(:admin) { create(:user, role: 'admin') }
  let(:jwt_token) { admin.generate_jwt }
  let(:valid_attributes) { { name: 'Hotel California', location: 'Los Angeles', amenities: 'Pool, Gym' } }
  let(:invalid_attributes) { { name: '', location: '', amenities: '' } }
  let!(:hotel) { create(:hotel) }

  path '/api/v1/hotels' do # rubocop:disable Metrics/BlockLength
    post 'Create a hotel' do # rubocop:disable Metrics/BlockLength
      security [Bearer: []]
      tags 'Hotels'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :attributes, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string, example: 'Hotel California' },
          location: { type: :string, example: 'Los Angeles' },
          amenities: { type: :string, example: 'Pool, Gym' }
        },
        required: %w[name location amenities]
      }

      response '201', 'Hotel created' do
        let(:Authorization) { "Bearer #{jwt_token}" }
        let(:attributes) { valid_attributes }

        example 'application/json', :success_example, {
          id: 1,
          name: 'Hotel California',
          location: 'Los Angeles',
          amenities: 'Pool, Gym'
        }
        run_test!
      end

      response '422', 'Invalid attributes' do
        let(:Authorization) { "Bearer #{jwt_token}" }
        let(:attributes) { invalid_attributes }

        example 'application/json', :error_example, {
          error: ["Name can't be blank", "Location can't be blank"]
        }
        run_test!
      end

      response '401', 'Unauthorized' do
        let(:Authorization) { nil }
        let(:attributes) { valid_attributes }

        example 'application/json', :unauthorized_example, { error: 'Unauthorized' }
        run_test!
      end
    end
  end

  path '/api/v1/hotels/{hotel_id}' do # rubocop:disable Metrics/BlockLength
    parameter name: :hotel_id, in: :path, type: :integer, description: 'ID of the hotel'

    put 'Update a hotel' do # rubocop:disable Metrics/BlockLength
      security [Bearer: []]
      tags 'Hotels'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :attributes, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string, example: 'Updated Hotel' },
          location: { type: :string, example: 'New York' },
          amenities: { type: :string, example: 'Pool, Gym, Spa' }
        }
      }

      response '200', 'Hotel updated' do
        let(:hotel_id) { hotel.id }
        let(:attributes) { { name: 'Updated Hotel' } }
        let(:Authorization) { "Bearer #{jwt_token}" }

        example 'application/json', :success_example, {
          id: 1,
          name: 'Updated Hotel',
          location: 'Los Angeles',
          amenities: 'Pool, Gym'
        }
        run_test!
      end

      response '422', 'Invalid hotel attributes' do
        let(:hotel_id) { hotel.id }
        let(:attributes) { invalid_attributes }
        let(:Authorization) { "Bearer #{jwt_token}" }

        example 'application/json', :error_example, { error: ["Name has already been taken"] }
        run_test!
      end

      response '404', 'Hotel not found' do
        let(:hotel_id) { 'invalid' }
        let(:attributes) { { name: 'Updated Hotel' } }
        let(:Authorization) { "Bearer #{jwt_token}" }

        example 'application/json', :not_found_example, { error: 'Hotel not found' }
        run_test!
      end
    end

    delete 'Delete a hotel' do
      security [Bearer: []]
      tags 'Hotels'
      consumes 'application/json'

      response '204', 'Hotel deleted' do
        let(:hotel_id) { hotel.id }
        let(:Authorization) { "Bearer #{jwt_token}" }

        run_test!
      end

      response '404', 'Hotel not found' do
        let(:hotel_id) { 'invalid' }
        let(:Authorization) { "Bearer #{jwt_token}" }

        example 'application/json', :not_found_example, { error: 'Hotel not found' }
        run_test!
      end

      response '401', 'Unauthorized' do
        let(:hotel_id) { hotel.id }
        let(:Authorization) { nil }

        example 'application/json', :unauthorized_example, { error: 'Unauthorized' }
        run_test!
      end
    end
  end
end

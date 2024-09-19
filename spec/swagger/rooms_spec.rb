require 'swagger_helper'

RSpec.describe 'api/v1/rooms', type: :request do
  let(:hotel) { create(:hotel) }
  let(:hotel_id) { hotel.id }
  let!(:room) { create(:room, hotel:) }
  let(:room_id) { room.id }
  let(:user) { create(:user) }
  let(:admin) { create(:user, role: 'admin') }
  let(:valid_attributes) { { number: '101', capacity: 2, amenities: 'WiFi, TV, Pool' } }
  let(:invalid_attributes) { { number: '', amenities: '' } }
  let(:check_in) { Date.today.to_s }
  let(:check_out) { (Date.today + 1.day).to_s }

  path '/api/v1/hotels/{hotel_id}/rooms' do # rubocop:disable Metrics/BlockLength
    post 'Create a room for a hotel (Admin only)' do # rubocop:disable Metrics/BlockLength
      security [Bearer: []]
      tags 'Rooms'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :hotel_id, in: :path, schema: { type: :integer, example: 1 }, required: true
      parameter name: :attributes, in: :body, schema: {
        type: :object,
        properties: {
          number: { type: :string, example: '101' },
          capacity: { type: :integer, example: 2 },
          amenities: { type: :string, example: 'WiFi, TV, Pool' }
        },
        required: %w[number capacity amenities]
      }

      response '201', 'Room created' do
        let(:Authorization) { "Bearer #{JwtService.encode(user_id: admin.id)}" }
        let(:attributes) { valid_attributes }

        example 'application/json', :success_example, {
          number: '101',
          capacity: 2,
          amenities: 'WiFi, TV, Pool'
        }

        run_test!
      end

      response '401', 'Unauthorized' do
        let(:Authorization) { '' }
        let(:attributes) { valid_attributes }

        example 'application/json', :error_example, {
          error: 'Unauthorized access'
        }

        run_test!
      end

      response '422', 'Invalid attributes' do
        let(:Authorization) { "Bearer #{JwtService.encode(user_id: admin.id)}" }
        let(:attributes) { invalid_attributes }

        example 'application/json', :error_example, {
          error: ["Number can't be blank", "Amenities can't be blank"]
        }

        run_test!
      end
    end
  end

  path '/api/v1/hotels/{hotel_id}/rooms/{room_id}' do # rubocop:disable Metrics/BlockLength
    put 'Update a room (Admin only)' do # rubocop:disable Metrics/BlockLength
      security [Bearer: []]
      tags 'Rooms'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :hotel_id, in: :path, schema: { type: :integer, example: 1 }, required: true
      parameter name: :room_id, in: :path, schema: { type: :integer, example: 1 }, required: true
      parameter name: :attributes, in: :body, schema: {
        type: :object,
        properties: {
          number: { type: :string, example: '202' },
          capacity: { type: :integer, example: 3 },
          amenities: { type: :string, example: 'AC, Pool' }
        },
        required: %w[number capacity amenities]
      }

      response '200', 'Room updated' do
        let(:Authorization) { "Bearer #{JwtService.encode(user_id: admin.id)}" }
        let(:attributes) { { number: 'updated number' } }

        example 'application/json', :success_example, {
          number: '202',
          capacity: 3,
          amenities: 'AC, Pool'
        }

        run_test!
      end

      response '404', 'Room not found' do
        let(:Authorization) { "Bearer #{JwtService.encode(user_id: admin.id)}" }
        let(:room_id) { 'invalid' }
        let(:attributes) { { number: 'updated number' } }

        example 'application/json', :error_example, {
          error: 'Room not found'
        }

        run_test!
      end

      response '422', 'Invalid attributes' do
        let(:Authorization) { "Bearer #{JwtService.encode(user_id: admin.id)}" }
        let(:attributes) { { number: '' } }

        example 'application/json', :error_example, {
          error: ["Number can't be blank"]
        }

        run_test!
      end
    end

    delete 'Delete a room (Admin only)' do
      security [Bearer: []]
      tags 'Rooms'
      produces 'application/json'

      parameter name: :hotel_id, in: :path, schema: { type: :integer, example: 1 }, required: true
      parameter name: :room_id, in: :path, schema: { type: :integer, example: 1 }, required: true

      response '204', 'Room deleted' do
        let(:Authorization) { "Bearer #{JwtService.encode(user_id: admin.id)}" }

        run_test!
      end

      response '404', 'Room not found' do
        let(:Authorization) { "Bearer #{JwtService.encode(user_id: admin.id)}" }
        let(:room_id) { 'invalid' }

        example 'application/json', :error_example, {
          error: 'Room not found'
        }

        run_test!
      end

      response '401', 'Unauthorized' do
        let(:Authorization) { '' }

        example 'application/json', :error_example, {
          error: 'Unauthorized access'
        }

        run_test!
      end
    end
  end

  path '/api/v1/hotels/{hotel_id}/rooms/available' do # rubocop:disable Metrics/BlockLength
    get 'List available rooms for a hotel' do # rubocop:disable Metrics/BlockLength
      security [Bearer: []]
      tags 'Rooms'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :hotel_id, in: :path, schema: { type: :integer, example: 1 }, required: true
      parameter name: :check_in, in: :query, schema: { type: :string, format: :date, example: '11/11/2024' },
                required: true
      parameter name: :check_out, in: :query, schema: { type: :string, format: :date, example: '12/11/2024' },
                required: true

      response '200', 'Available rooms found' do
        let(:Authorization) { "Bearer #{JwtService.encode(user_id: user.id)}" }

        example 'application/json', :success_example, [{
          number: '101',
          hotel_id: 1,
          capacity: 2,
          amenities: 'WiFi, TV, Pool'
        }]

        run_test!
      end

      response '401', 'Unauthorized' do
        let(:Authorization) { '' }

        example 'application/json', :error_example, {
          error: 'Unauthorized access'
        }

        run_test!
      end

      response '422', 'Invalid date format' do
        let(:Authorization) { JwtService.encode(user_id: user.id) }
        let(:check_in) { 'invalid-date' }
        let(:check_out) { 'invalid-date' }

        example 'application/json', :error_example, {
          error: 'Invalid date format'
        }

        run_test!
      end

      response '422', 'check-in and check-out dates are required' do
        let(:Authorization) { JwtService.encode(user_id: user.id) }
        let(:check_in) { '' }

        example 'application/json', :error_example, {
          error: 'Check-in and check-out dates are required'
        }

        run_test!
      end

      response '200', 'No available rooms found' do
        let(:Authorization) { JwtService.encode(user_id: user.id) }
        before do
          allow(Room).to receive(:available).and_return([])
        end

        example 'application/json', :success_example, []

        run_test! 
      end
    end
  end
end

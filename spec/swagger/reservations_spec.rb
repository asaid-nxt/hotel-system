require 'swagger_helper'

RSpec.describe 'api/v1/reservations', type: :request do
  let(:hotel) { create(:hotel) }
  let(:hotel_id) { hotel.id }
  let(:room) { create(:room, hotel:) }
  let(:room_id) { room.id }
  let(:user) { create(:user) }
  let(:check_in) { Date.today.to_s }
  let(:check_out) { (Date.today + 1.day).to_s }

  path '/api/v1/reservations' do # rubocop:disable Metrics/BlockLength
    get 'Retrieve a list of reservations (past, current, and future) (User only)' do # rubocop:disable Metrics/BlockLength
      security [Bearer: []]
      tags 'Reservations'
      produces 'application/json'

      response '200', 'Reservations retrieved successfully' do # rubocop:disable Metrics/BlockLength
        let(:Authorization) { "Bearer #{JwtService.encode(user_id: user.id)}" }
        let!(:current_reservation) { create(:reservation, check_in: Date.today, check_out: Date.tomorrow, user:) }
        let!(:future_reservation) {
                                    create(:reservation, check_in: Date.tomorrow, check_out: Date.today + 2.days, user:)
                                  }
        example 'application/json', :success_example, {
          past: [],
          current: [{
            full_name: 'Harry Kane',
            avatar: '/path/to/image.jpg',
            hotel_name: 'Hotel Name',
            room_number: '101',
            check_in: '2023-09-15',
            check_out: '2023-09-20',
            user_preferences: 'Gym, Pool'
             }],
          future: [{
            full_name: 'Harry Kane',
            avatar: '/path/to/image.jpg',
            hotel_name: 'Hotel Name',
            room_number: '101',
            check_in: '2023-09-15',
            check_out: '2023-09-20',
            user_preferences: 'Gym, Pool'
             }]
        }
        run_test!
      end

      response '401', 'Unauthorized' do
        let(:Authorization) { 'invalid_token' }

        schema type: :object, properties: { error: { type: :string, example: 'Unauthorized' } }

        run_test!
      end
    end
  end

  path '/api/v1/reservations/all' do # rubocop:disable Metrics/BlockLength
    get 'Fetch all reservations (Admin only)' do # rubocop:disable Metrics/BlockLength
      tags 'Reservations'
      produces 'application/json'
      security [Bearer: []]

      response '200', 'list of reservations' do
        let(:admin) { create(:user, username: 'admin', role: 'admin') }
        let(:Authorization) { "Bearer #{JwtService.encode(user_id: admin.id)}" }

        run_test!

        example 'application/json', :example_response, [
          {
            full_name: 'Harry Kane',
            avatar: '/path/to/image.jpg',
            hotel_name: 'Hotel Name',
            room_number: '101',
            check_in: '2023-09-15',
            check_out: '2023-09-20',
            user_preferences: 'Gym, Pool'
          },
          {
            full_name: 'Harry Potter',
            avatar: '/path/to/image.jpg',
            hotel_name: 'Hotel Name',
            room_number: '102',
            check_in: '2023-09-15',
            check_out: '2023-09-20',
            user_preferences: 'Tennis Court'
          }
        ]
      end

      response '401', 'unauthorized' do
        let(:Authorization) { 'invalid_token' }
        run_test!
      end
    end
  end

  path '/api/v1/hotels/{hotel_id}/rooms/{room_id}/reservations' do # rubocop:disable Metrics/BlockLength
    post 'Create a reservation for a room (User only)' do # rubocop:disable Metrics/BlockLength
      security [Bearer: []]
      tags 'Reservations'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :hotel_id, in: :path, schema: { type: :integer, example: 1 }, required: true
      parameter name: :room_id, in: :path, schema: { type: :integer, example: 1 }, required: true
      parameter name: :reservation, in: :body, schema: {
        type: :object,
        properties: {
          check_in: { type: :string, format: :date, example: Date.today },
          check_out: { type: :string, format: :date, example: Date.tomorrow }
        },
        required: %w[check_in check_out]
      }

      response '201', 'Reservation created successfully' do
        let(:Authorization) { "Bearer #{JwtService.encode(user_id: user.id)}" }
        let(:reservation) { { check_in:, check_out: } }

        example 'application/json', :success_example, {
          full_name: 'Harry Kane',
          avatar: '/path/to/image.jpg',
          hotel_name: 'Hotel Name',
          room_number: '101',
          check_in: '2023-09-15',
          check_out: '2023-09-20',
          user_preferences: 'Gym, Pool'
        }

        run_test!
      end

      response '401', 'Unauthorized' do
        let(:Authorization) { '' }
        let(:reservation) { { check_in:, check_out: } }

        schema type: :object, properties: { error: { type: :string, example: 'Unauthorized' } }

        run_test!
      end

      response '404', 'Room not found' do
        let(:Authorization) { "Bearer #{JwtService.encode(user_id: user.id)}" }
        let(:room_id) { 'invalid' }
        let(:reservation) { { check_in:, check_out: } }

        schema type: :object, properties: { error: { type: :string, example: 'Room not found' } }

        run_test!
      end

      response '422', 'Room is not available for the selected dates' do
        let(:Authorization) { "Bearer #{JwtService.encode(user_id: user.id)}" }
        let!(:existing_reservation) { create(:reservation, room:, check_in:, check_out:, user:) }
        let(:reservation) { { check_in:, check_out: } }

        schema type: :object,
               properties: { error: { type: :array, example: ['Room is not available for the selected dates'] } }

        run_test!
      end

      response '422', 'Invalid date format' do
        let(:Authorization) { "Bearer #{JwtService.encode(user_id: user.id)}" }
        let(:reservation) { { check_in: 'invalid-date', check_out: 'invalid-date' } }

        schema type: :object, properties: { error: { type: :string, example: 'Invalid date format' } }

        run_test!
      end

      response '422', 'Check-in and check-out dates are required' do
        let(:Authorization) { "Bearer #{JwtService.encode(user_id: user.id)}" }
        let(:reservation) { { check_in: '' } }

        schema type: :object,
               properties: { error: { type: :string, example: 'Check-in and check-out dates are required' } }

        run_test!
      end
    end
  end
end

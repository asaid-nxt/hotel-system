require 'swagger_helper'

RSpec.describe 'api/v1/reservations', type: :request do
  let(:hotel) { create(:hotel) }
  let(:hotel_id) { hotel.id }
  let(:room) { create(:room, hotel:) }
  let(:room_id) { room.id }
  let(:user) { create(:user) }
  let(:check_in) { Date.today.to_s }
  let(:check_out) { (Date.today + 1.day).to_s }

  path '/api/v1/reservations' do
    get 'Retrieve a list of reservations (past, current, and future) (User only)' do
      security [Bearer: []]
      tags 'Reservations'
      produces 'application/json'

      response '200', 'Reservations retrieved successfully' do
        let(:Authorization) { "Bearer #{JwtService.encode(user_id: user.id)}" }
        let!(:current_reservation) { create(:reservation, check_in: Date.today, check_out: Date.tomorrow, user:) }
        let!(:future_reservation) {
                                    create(:reservation, check_in: Date.tomorrow, check_out: Date.today + 2.days, user:)
                                  }
        example 'application/json', :success_example, {
          past: [{ id: 1, room_id: 5, user_id: 3, check_in: '2024-09-13', check_out: '2024-09-14' }],
          current: [{ id: 2, room_id: 5, user_id: 3, check_in: '2024-09-17', check_out: '2024-09-18' }],
          future: [{ id: 3, room_id: 5, user_id: 3, check_in: '2024-09-20', check_out: '2024-09-21' }]
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
            id: 1,
            check_in: '2024-10-01',
            check_out: '2024-10-05',
            room_id: 10,
            user_id: 2,
            created_at: '2024-09-20T10:00:00.000Z',
            updated_at: '2024-09-20T10:00:00.000Z'
          },
          {
            id: 2,
            check_in: '2024-09-25',
            check_out: '2024-09-30',
            room_id: 12,
            user_id: 3,
            created_at: '2024-09-20T09:30:00.000Z',
            updated_at: '2024-09-20T09:30:00.000Z'
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
          check_in: { type: :string, format: :date, example: '2024-09-17' },
          check_out: { type: :string, format: :date, example: '2024-09-18' }
        },
        required: %w[check_in check_out]
      }

      response '201', 'Reservation created successfully' do
        let(:Authorization) { "Bearer #{JwtService.encode(user_id: user.id)}" }
        let(:reservation) { { check_in:, check_out: } }

        schema type: :object,
               properties: {
                 id: { type: :integer },
                 room_id: { type: :integer },
                 user_id: { type: :integer },
                 check_in: { type: :string, format: :date },
                 check_out: { type: :string, format: :date }
               },
               required: %w[id room_id user_id check_in check_out]

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

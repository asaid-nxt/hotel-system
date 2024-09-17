require 'swagger_helper'

RSpec.describe 'api/v1/reservations', type: :request do
  let(:hotel) { create(:hotel) }
  let(:hotel_id) { hotel.id }
  let(:room) { create(:room, hotel:) }
  let(:room_id) { room.id }
  let(:user) { create(:user) }
  let(:check_in) { Date.today.to_s }
  let(:check_out) { (Date.today + 1.day).to_s }

  path '/api/v1/hotels/{hotel_id}/rooms/{room_id}/reservations' do
    post 'Create a reservation for a room' do
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

        schema type: :object, properties: { error: { type: :string, example: 'Room is not available for the selected dates' } }

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

        schema type: :object, properties: { error: { type: :string, example: 'Check-in and check-out dates are required' } }

        run_test!
      end
    end
  end
end

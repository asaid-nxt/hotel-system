require 'swagger_helper'

JWT_TOKEN = 'Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoyMH0.Kzb9dwgjEYPDKCKTmjFRiBrKTBiyrgVHaMojU6bdKhY'

RSpec.describe 'api/v1/rooms', type: :request do
  let(:hotel) { create(:hotel) }
  let(:hotel_id) { hotel.id }
  let(:check_in) { Date.today.to_s }
  let(:check_out) { (Date.today + 1.day).to_s }
  let(:user) { create(:user) }
  let!(:room) { create(:room, hotel:) }

  path '/api/v1/hotels/{hotel_id}/rooms/available' do
    get 'List available rooms for a hotel' do
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

        schema type: :array,
               items: {
                 type: :object,
                 properties: {
                   number: { type: :string },
                   hotel_id: { type: :integer },
                   capacity: { type: :integer },
                   amenities: { type: :text, example: 'amenities' }
                 },
                 required: %w[number hotel_id capacity amenities]
               }

        run_test! do
          expect(response.status).to eq(200)
          expect(JSON.parse(response.body).size).to eq(1)
          expect(JSON.parse(response.body)[0]['number']).to eq(room.number)
        end
      end

      response '401', 'Unauthorized' do
        let(:Authorization) { '' }

        schema type: :object, properties: { error: { type: :string } }

        run_test!
      end

      response '422', 'Invalid date format' do
        let(:Authorization) { JwtService.encode(user_id: user.id) }
        let(:check_in) { 'invalid-date' }
        let(:check_out) { 'invalid-date' }

        schema type: :object,
               properties: {
                 error: { type: :string }
               },
               required: ['error']

        run_test! do
          expect(response.status).to eq(422)
          expect(JSON.parse(response.body)['error']).to eq('Invalid date format')
        end
      end

      response '400', 'Check-in and check-out dates are required' do
        let(:Authorization) { JwtService.encode(user_id: user.id) }
        let(:check_in) { '' }

        schema type: :object,
               properties: {
                 error: { type: :string }
               },
               required: ['error']

        run_test! do
          expect(response.status).to eq(400)
          expect(JSON.parse(response.body)['error']).to eq('Check-in and check-out dates are required')
        end
      end

      response '200', 'No available rooms found' do
        let(:Authorization) { JwtService.encode(user_id: user.id) }
        before do
          allow(Room).to receive(:available).and_return([])
        end

        schema type: :array, items: {}

        run_test! do
          expect(response.status).to eq(200)
          expect(JSON.parse(response.body)).to be_empty
        end
      end
    end
  end
end

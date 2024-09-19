require 'rails_helper'

RSpec.describe 'Rooms API', type: :request do # rubocop:disable Metrics/BlockLength
  let(:user) { create(:user) }
  let(:admin) { create(:user, role: 'admin') }
  let(:hotel) { create(:hotel) }
  let!(:room) { create(:room, number: '1', hotel:) }
  let(:check_in) { Date.today }
  let(:check_out) { Date.today + 3.days }
  let(:jwt_token) { user.generate_jwt }
  let(:headers) { { 'Authorization' => jwt_token } }
  let(:admin_headers) { { 'Authorization' => admin.generate_jwt } }
  let(:valid_attributes) { { number: '1A', capacity: 2, amenities: 'Pool' } }
  let(:invalid_attributes) { { number: '', amenities: '' } }

  describe 'POST /api/v1/hotels/:hotel_id/rooms' do # rubocop:disable Metrics/BlockLength
    describe 'when admin is authenticated' do
      context 'with valid attributes' do
        before do
          post "/api/v1/hotels/#{hotel.id}/rooms", params: { room: valid_attributes },
                                                   headers: admin_headers
        end

        it 'creates a room' do
          expect(response).to have_http_status :created
          expect(json_response['number']).to eq('1A')
        end
      end

      context 'with invalid attributes' do
        before do
          post "/api/v1/hotels/#{hotel.id}/rooms", params: { room: invalid_attributes },
                                                   headers: admin_headers
        end

        it 'returns an error' do
          expect(response).to have_http_status :unprocessable_entity
          expect(json_response).to eq({ 'error' => ["Number can't be blank", "Capacity can't be blank",
                                                    'Capacity is not a number'] })
        end
      end
    end

    describe 'when user is authenticated' do
      before do
        post "/api/v1/hotels/#{hotel.id}/rooms", params: { room: valid_attributes },
                                                 headers:
      end

      it 'returns Unauthorized error' do
        expect(response).to have_http_status :unauthorized
        expect(json_response).to eq({ 'error' => 'Unauthorized' })
      end
    end

    describe 'when there is no authentication' do
      it 'return unauthorized error' do
        post "/api/v1/hotels/#{hotel.id}/rooms", params: { room: valid_attributes }
        expect(response).to have_http_status :unauthorized
        expect(json_response).to eq({ 'error' => 'Unauthorized' })
      end
    end
  end

  describe 'PUT /api/v1/hotels/:hotel_id/rooms/:room_id' do # rubocop:disable Metrics/BlockLength
    describe 'when room exists' do
      context 'with valid attributes' do
        before do
          put "/api/v1/hotels/#{hotel.id}/rooms/#{room.id}",
              params: { room: { number: 'updated number' } }, headers: admin_headers
        end

        it 'updates the room' do
          expect(response).to have_http_status :ok
          expect(json_response['number']).to eq('updated number')
        end
      end

      context 'with invalid attributes' do
        before do
          put "/api/v1/hotels/#{hotel.id}/rooms/#{room.id}",
              params: { room: { number: '' } }, headers: admin_headers
        end

        it 'returns an error' do
          expect(response).to have_http_status :unprocessable_entity
          expect(json_response).to eq({ 'error' => ["Number can't be blank"] })
        end
      end
    end

    describe "when room doesn't exist" do
      before do
        put "/api/v1/hotels/#{hotel.id}/rooms/invalid",
            params: { room: { number: 'updated number' } }, headers: admin_headers
      end

      it 'returns not_found error' do
        expect(response).to have_http_status :not_found
        expect(json_response).to eq({ 'error' => 'Room not found' })
      end
    end
  end


  describe 'DELETE /api/v1/hotels/:hotel_id/rooms/:room_id' do # rubocop:disable Metrics/BlockLength
    describe 'when room exists' do
      before do
        delete "/api/v1/hotels/#{hotel.id}/rooms/#{room.id}", headers: admin_headers
      end

      it 'deletes the room' do
        expect(response).to have_http_status :no_content
      end
    end

    describe 'when room does not exist' do
      before do
        delete "/api/v1/hotels/#{hotel.id}/rooms/invalid", headers: admin_headers
      end

      it 'return not found error' do
        expect(response).to have_http_status :not_found
        expect(json_response).to eq({ 'error' => 'Room not found' })
      end
    end

    describe 'when user is not authenticated' do
      before do
        delete "/api/v1/hotels/#{hotel.id}/rooms/#{room.id}"
      end

      it 'return Unauthorized error' do
        expect(response).to have_http_status :unauthorized
        expect(json_response).to eq({ 'error' => 'Unauthorized' })
      end
    end
  end

  describe 'GET /api/v1/hotels/:hotel_id/rooms/available' do # rubocop:disable Metrics/BlockLength
    context 'when the user is authenticated and provides valid dates' do
      before do
        get "/api/v1/hotels/#{hotel.id}/rooms/available", params: { hotel_id: hotel.id, check_in:, check_out: },
                                                          headers:
      end

      it 'return available rooms' do
        expect(response).to have_http_status :ok
        expect(JSON.parse(response.body).size).to eq(1)
      end
    end

    context 'when date format is not valid' do
      let(:check_in) { 'invalid-format' }

      before do
        get "/api/v1/hotels/#{hotel.id}/rooms/available", params: { hotel_id: hotel.id, check_in:, check_out: },
                                                          headers:
      end

      it 'return an error for invalid format' do
        expect(response).to have_http_status :unprocessable_entity
        expect(JSON.parse(response.body)).to eq({ 'error' => 'Invalid date format' })
      end
    end

    context 'when dates are missing' do
      before do
        get "/api/v1/hotels/#{hotel.id}/rooms/available", params: { hotel_id: hotel.id },
                                                          headers:
      end

      it 'return an error for missing data' do
        expect(response).to have_http_status :unprocessable_entity
        expect(JSON.parse(response.body)).to eq({ 'error' => 'check-in and check-out dates are required' })
      end
    end

    context 'when user is not authenticated' do
      let(:headers) {}
      before do
        get "/api/v1/hotels/#{hotel.id}/rooms/available", params: { hotel_id: hotel.id, check_in:, check_out: },
                                                          headers:
      end

      it 'return unauthorized error' do
        expect(response).to have_http_status :unauthorized
      end
    end
  end
end

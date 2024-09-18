require 'rails_helper'

RSpec.describe 'Reservations API', type: :request do
  let(:user) { create(:user) }
  let(:jwt_token) { user.generate_jwt }
  let(:headers) { { 'Authorization' => jwt_token } }
  let(:hotel) { create(:hotel) }
  let(:room) { create(:room) }
  let(:check_in) { Date.today }
  let(:check_out) { Date.tomorrow }

  describe 'GET /api/v1/reservations' do
    let!(:past_reservation) { create(:reservation, check_in: Date.today - 3.days, check_out: Date.yesterday, user:) }
    let!(:current_reservation) { create(:reservation, check_in: Date.today, check_out: Date.tomorrow, user:) }
    let!(:future_reservation) { create(:reservation, check_in: Date.tomorrow, check_out: Date.today + 2.days, user:) }

    describe 'when user is authenticated' do
      context 'when user have reservations' do
        before do
          get '/api/v1/reservations', headers:
        end
        it 'returns the past, current and future reservations' do
          expect(response).to have_http_status :ok
          expect(json_response['past']).to include(JSON.parse(ActiveModelSerializers::SerializableResource.new(
            past_reservation, each_serializer: ReservationSerializer
          ).to_json))
          expect(json_response['current']).to include(JSON.parse(ActiveModelSerializers::SerializableResource.new(
            current_reservation, each_serializer: ReservationSerializer
          ).to_json))
          expect(json_response['future']).to include(JSON.parse(ActiveModelSerializers::SerializableResource.new(
            future_reservation, each_serializer: ReservationSerializer
          ).to_json))
        end
      end

      context 'when user have no reservations' do
        let(:other_user) { create(:user, username: 'test1') }
        let(:other_headers) { { 'Authorization' => "Bearer #{other_user.generate_jwt}" } }

        before do
          get '/api/v1/reservations', headers: other_headers
        end

        it 'returns empty past, current and future reservations' do
          expect(response).to have_http_status :ok
          expect(json_response['past']).to be_empty
          expect(json_response['current']).to be_empty
          expect(json_response['future']).to be_empty
        end
      end
    end

    describe 'when user is not authenticated' do
      before do
        get '/api/v1/reservations', headers: { 'Authorization' => 'invalid_token' }
      end

      it 'return an error Unauthoraized' do
        expect(response).to have_http_status :unauthorized
      end
    end
  end

  describe 'POST /api/v1/hotels/:hotel_id/rooms/:room_id/reservations' do
    describe 'when user is authenticated and room is available' do
      before do
        post "/api/v1/hotels/#{hotel.id}/rooms/#{room.id}/reservations",
             params: { reservation: { check_in:, check_out: } }, headers:
      end

      it 'makes a reservation' do
        expect(response).to have_http_status :created
        expect(json_response).to include(
          'id' => be_present,
          'room_id' => room.id,
          'user_id' => be_present
        )
      end
    end

    describe 'when room is not found' do
      before do
        post "/api/v1/hotels/#{hotel.id}/rooms/invalid/reservations",
             params: { reservation: { check_in:, check_out: } }, headers:
      end

      it 'return an error' do
        expect(response).to have_http_status :not_found
        expect(json_response).to eq({ 'error' => 'Room not found' })
      end
    end

    describe 'when room is not available' do
      let!(:reservation) { create(:reservation, room:, check_in:, check_out:, user:) }
      before do
        post "/api/v1/hotels/#{hotel.id}/rooms/#{room.id}/reservations",
             params: { reservation: { check_in:, check_out: } }, headers:
      end

      it 'returns an error' do
        expect(response).to have_http_status :unprocessable_entity
        expect(json_response).to eq({ 'error' => 'Room is not available for the selected dates' })
      end
    end

    describe 'when user is not authenticated' do
      before do
        post "/api/v1/hotels/#{hotel.id}/rooms/#{room.id}/reservations",
             params: { reservation: { check_in:, check_out: } }, headers: { 'Authorization' => 'invalid_token' }
      end

      it 'returns an error' do
        expect(response).to have_http_status :unauthorized
        expect(json_response).to eq({ 'error' => 'Unauthorized' })
      end
    end

    describe 'when check_in is missing' do
      before do
        post "/api/v1/hotels/#{hotel.id}/rooms/#{room.id}/reservations",
             params: { reservation: { check_out: } }, headers:
      end
      it 'returns an error' do
        expect(response).to have_http_status :unprocessable_entity
        expect(json_response).to eq({ 'error' => 'check-in and check-out dates are required' })
      end
    end

    describe 'when check_out is missing' do
      before do
        post "/api/v1/hotels/#{hotel.id}/rooms/#{room.id}/reservations",
             params: { reservation: { check_in: } }, headers:
      end
      it 'returns an error' do
        expect(response).to have_http_status :unprocessable_entity
        expect(json_response).to eq({ 'error' => 'check-in and check-out dates are required' })
      end
    end

    describe 'when check in is invalid' do
      before do
        post "/api/v1/hotels/#{hotel.id}/rooms/#{room.id}/reservations",
             params: { reservation: { check_in: 'invalid', check_out: } }, headers:
      end

      it 'return an error' do
        expect(response).to have_http_status :unprocessable_entity
        expect(json_response).to eq({ 'error' => 'Invalid date format' })
      end
    end
  end
end

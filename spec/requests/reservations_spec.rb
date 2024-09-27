require 'rails_helper'

RSpec.describe 'Reservations API', type: :request do # rubocop:disable Metrics/BlockLength
  let(:user) { create(:user) }
  let(:jwt_token) { user.generate_jwt }
  let(:headers) { { 'Authorization' => jwt_token } }
  let(:hotel) { create(:hotel) }
  let(:room) { create(:room) }
  let(:check_in) { Date.today }
  let(:check_out) { Date.tomorrow }

  describe 'GET /api/v1/reservations' do # rubocop:disable Metrics/BlockLength
    describe 'when user is authenticated' do # rubocop:disable Metrics/BlockLength
      let!(:current_reservation) { create(:reservation, check_in: Date.today, check_out: Date.tomorrow, user:) }
      let!(:future_reservation) { create(:reservation, check_in: Date.tomorrow, check_out: Date.today + 2.days, user:) }
      context 'when user have reservations' do
        before do
          get '/api/v1/reservations', headers:
        end
        it 'returns the past, current and future reservations' do
          expect(response).to have_http_status :ok
          expect(json_response['past']).to be_blank
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

    describe 'pagination' do
      let!(:current_reservation) { create_list(:reservation, 15, check_in: Date.today, check_out: Date.tomorrow, user:) }
      let!(:future_reservation) { create_list(:reservation, 15, check_in: Date.tomorrow, check_out: Date.today + 2.days, user:) }

      before do
        get '/api/v1/reservations', params: { page: 1, per_page: 10 }, headers:
      end

      it 'returns the paginated reservations with proper metadata' do
        expect(response).to have_http_status :ok

        # Check the reservation data
        expect(json_response['current'].size).to eq(10) # Assuming default per_page is 10
        expect(json_response['meta']['current_page']).to eq(1)
        expect(json_response['meta']['total_pages']).to be > 1
        expect(json_response['meta']['total_count']).to eq(30)
      end

      context 'when requesting page 2' do
        before do
          get '/api/v1/reservations', params: { page: 2, per_page: 10 }, headers:
        end

        it 'returns the second page of reservations' do
          expect(response).to have_http_status :ok
          expect(json_response['current'].size).to eq(5) # Assuming there are 15 reservations and 10 per page
          expect(json_response['meta']['current_page']).to eq(2)
          expect(json_response['meta']['total_pages']).to eq(3)
        end
      end
    end
  end

  describe 'GET /api/v1/reservations/all' do # rubocop:disable Metrics/BlockLength
    let(:admin) { create(:user, username: 'admin', role: 'admin') }
    let(:admin_headers) { { 'Authorization': admin.generate_jwt } }
    describe 'when admin is authenticated' do
      let!(:reservations) { create_list(:reservation, 3, user:) }

      before do
        get '/api/v1/reservations/all', headers: admin_headers
      end

      it 'return all reservations' do
        expect(response).to have_http_status :ok
        expect(json_response['reservations'].size).to eq(3)
      end
    end

    describe 'when admin is not authenticated' do
      let!(:reservations) { create_list(:reservation, 3, user:) }
      before do
        get '/api/v1/reservations/all'
      end

      it 'returns an Unauthorized error' do
        expect(response).to have_http_status :unauthorized
      end
    end

    describe 'pagination' do
      let!(:reservations) { create_list(:reservation, 30, user:) }

      context 'with default pagination' do
        it 'returns the default number of records per page' do
          get '/api/v1/reservations/all', headers: admin_headers

          expect(json_response['reservations'].size).to eq(10) # Assuming 10 is your default per_page
          expect(json_response['meta']['current_page']).to eq(1)
          expect(json_response['meta']['total_pages']).to eq(3)
        end
      end

      context 'with custom per_page parameter' do
        it 'returns the correct number of records per page' do
          get '/api/v1/reservations/all', params: { per_page: 5 }, headers: admin_headers

          expect(json_response['reservations'].size).to eq(5)
          expect(json_response['meta']['total_pages']).to eq(6)
        end
      end
    end
  end

  describe 'POST /api/v1/hotels/:hotel_id/rooms/:room_id/reservations' do # rubocop:disable Metrics/BlockLength
    describe 'when user is authenticated and room is available' do
      before do
        post "/api/v1/hotels/#{hotel.id}/rooms/#{room.id}/reservations",
             params: { reservation: { check_in:, check_out: } }, headers:
      end

      it 'makes a reservation' do
        expect(response).to have_http_status :created
        expect(json_response).to include(
          'room_number' => room.number,
          'hotel_name' => be_present
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
        expect(json_response).to eq({ 'error' => ['Room is not available for the selected dates'] })
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

require 'rails_helper'

RSpec.describe 'Rooms API' do
  let(:user) { create(:user) }
  let(:hotel) { create(:hotel) }
  let!(:room) { create(:room, hotel:) }
  let(:check_in) { Date.today }
  let(:check_out) { Date.today + 3.days }
  let(:headers) { { 'Authorization' => jwt_token } }
  let(:jwt_token) { user.generate_jwt }

  describe 'GET /api/v1/hotels/:hotel_id/rooms/available' do
    context 'when the user is authenticated and provides valid dates' do
      before do
        get "/api/v1/hotels/#{hotel.id}/rooms/available", params: { hotel_id: hotel.id, check_in:, check_out: },
                                                          headers:
      end

      it 'return available rooms' do
        expect(response).to have_http_status :ok
        expect(JSON.parse(response.body)).to eq([room].as_json)
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
        expect(response).to have_http_status :bad_request
        expect(JSON.parse(response.body)).to eq({ 'error' => 'Check-in and check-out dates are required' })
      end
    end

    context "when user is not authenticated" do
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

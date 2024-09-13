require 'rails_helper'

RSpec.describe Api::V1::RoomsController, type: :controller do
  let(:user) { create(:user) }
  let(:token) { user.generate_jwt }

  describe 'GET #available' do
    let(:hotel) { create(:hotel) }
    let(:room1) { create(:room, hotel:) }
    let(:room2) { create(:room, hotel:) }

    context 'when the user is authenticated' do
      before do
        request.headers['Authorization'] = token
      end

      context 'with valid check-in and check-out dates' do
        it 'returns the available rooms for the hotel' do
          allow(Room).to receive(:available).and_return([room1, room2])
          get :available, params: { hotel_id: hotel.id, check_in: '2024-09-15', check_out: '2024-09-20' }

          expect(response).to have_http_status(:ok)
          expect(JSON.parse(response.body)).to eq([room1, room2].as_json)
        end
      end

      context 'when check-in or check-out dates are missing' do
        it 'returns an error for missing check-in date' do
          get :available, params: { hotel_id: hotel.id, check_out: '2024-09-20' }

          expect(response).to have_http_status(:bad_request)
          expect(JSON.parse(response.body)).to eq({ 'error' => 'Check-in and check-out dates are required' })
        end

        it 'returns an error for missing check-out date' do
          get :available, params: { hotel_id: hotel.id, check_in: '2024-09-15' }

          expect(response).to have_http_status(:bad_request)
          expect(JSON.parse(response.body)).to eq({ 'error' => 'Check-in and check-out dates are required' })
        end
      end

      context 'when an invalid date format is provided' do
        it 'returns an error for invalid check-in date' do
          get :available, params: { hotel_id: hotel.id, check_in: 'invalid_date', check_out: '2024-09-20' }

          expect(response).to have_http_status(:unprocessable_entity)
          expect(JSON.parse(response.body)).to eq({ 'error' => 'Invalid date format' })
        end

        it 'returns an error for invalid check-out date' do
          get :available, params: { hotel_id: hotel.id, check_in: '2024-09-15', check_out: 'invalid_date' }

          expect(response).to have_http_status(:unprocessable_entity)
          expect(JSON.parse(response.body)).to eq({ 'error' => 'Invalid date format' })
        end
      end
    end

    context 'when the user is not authenticated' do
      before do
        request.headers['Authorization'] = nil
      end

      it 'returns an unauthorized status' do
        get :available, params: { hotel_id: hotel.id, check_in: '2024-09-15', check_out: '2024-09-20' }

        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)).to eq({ 'error' => 'Unauthorized' })
      end
    end
  end
end

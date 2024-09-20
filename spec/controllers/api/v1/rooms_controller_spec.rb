require 'rails_helper'

RSpec.describe Api::V1::RoomsController, type: :controller do # rubocop:disable Metrics/BlockLength
  let(:user) { create(:user) }
  let(:admin) { create(:user, role: 'admin') }
  let!(:hotel) { create(:hotel) }
  let!(:room) { create(:room, hotel:) }
  let(:valid_attributes) do
    {
      number: '1A',
      capacity: 2,
      amenities: 'Pool',
      image: fixture_file_upload(Rails.root.join('spec', 'fixtures', 'files', 'hotel.jpg'), 'image/jpg')
    }
  end
  let(:invalid_attributes) { { number: '', amenities: '' } }

  describe 'POST #create' do # rubocop:disable Metrics/BlockLength
    before do
      allow_any_instance_of(described_class).to receive(:authenticate_admin!).and_return(true)
    end
    describe 'with valid params' do
      it 'creates a room' do
        expect do
          post(:create, params: { hotel_id: hotel.id, room: valid_attributes })
        end.to change(Room, :count).by(1)
        expect(response).to have_http_status :created
        expect(json_response['room_number']).to eq('1A')
        expect(Room.last.image).to be_attached
      end
    end

    describe 'with invalid attributes' do
      it "doesn't create a room" do
        expect do
          post(:create, params: { hotel_id: hotel.id, room: invalid_attributes })
        end.to change(Room, :count).by(0)
        expect(Room.last.image).not_to be_attached
      end

      it 'returns an error' do
        post(:create, params: { hotel_id: hotel.id, room: invalid_attributes })
        expect(response).to have_http_status :unprocessable_entity
        expect(json_response).to eq({ 'error' => ["Number can't be blank", "Capacity can't be blank",
                                                  'Capacity is not a number'] })
      end
    end
  end

  describe 'PUT #update' do
    before do
      allow_any_instance_of(described_class).to receive(:authenticate_admin!).and_return(true)
    end
    describe 'with valid attributes' do
      it 'updates the selected room' do
        put :update, params: { hotel_id: hotel.id, id: room.id, room: { number: 'updated number' } }
        expect(json_response['room_number']).to eq('updated number')
        expect(response).to have_http_status :ok
      end
    end

    describe 'with invalid attributes' do
      it 'returns an error' do
        put :update, params: { hotel_id: hotel.id, id: room.id, room: { number: '' } }
        expect(json_response).to eq({ 'error' => ["Number can't be blank"] })
        expect(response).to have_http_status :unprocessable_entity
      end
    end
  end

  describe 'DELETE #destroy' do
    before do
      allow_any_instance_of(described_class).to receive(:authenticate_admin!).and_return(true)
    end
    it 'deletes the hotel' do
      expect do
        delete :destroy, params: { hotel_id: hotel.id, id: room.id }
      end.to change(Room, :count).by(-1)
      expect(response).to have_http_status :no_content
    end
  end

  describe 'GET #available' do # rubocop:disable Metrics/BlockLength
    let(:hotel) { create(:hotel) }
    let(:room1) { create(:room, hotel:) }
    let(:room2) { create(:room, hotel:) }

    context 'when the user is authenticated' do # rubocop:disable Metrics/BlockLength
      before do
        allow_any_instance_of(described_class).to receive(:authenticate_user!).and_return(true)
      end

      context 'with valid check-in and check-out dates' do
        it 'returns the available rooms for the hotel' do
          allow(Room).to receive(:available).and_return([room1, room2])
          get :available, params: { hotel_id: hotel.id, check_in: '2024-09-15', check_out: '2024-09-20' }

          expect(response).to have_http_status(:ok)
          expect(JSON.parse(response.body).size).to eq(2)
        end
      end

      context 'when check-in or check-out dates are missing' do
        it 'returns an error for missing check-in date' do
          get :available, params: { hotel_id: hotel.id, check_out: '2024-09-20' }

          expect(response).to have_http_status(:unprocessable_entity)
          expect(JSON.parse(response.body)).to eq({ 'error' => 'check-in and check-out dates are required' })
        end

        it 'returns an error for missing check-out date' do
          get :available, params: { hotel_id: hotel.id, check_in: '2024-09-15' }

          expect(response).to have_http_status(:unprocessable_entity)
          expect(JSON.parse(response.body)).to eq({ 'error' => 'check-in and check-out dates are required' })
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
      it 'returns an unauthorized status' do
        get :available, params: { hotel_id: hotel.id, check_in: '2024-09-15', check_out: '2024-09-20' }

        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)).to eq({ 'error' => 'Unauthorized' })
      end
    end
  end
end

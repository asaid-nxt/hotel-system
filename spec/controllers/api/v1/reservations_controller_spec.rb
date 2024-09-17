require 'rails_helper'

RSpec.describe Api::V1::ReservationsController, type: :controller do
  describe 'POST #create' do
    let(:hotel) { create(:hotel) }
    let(:room) { create(:room, hotel:) }
    let(:check_in) { Date.today }
    let(:check_out) { Date.tomorrow }

    before do
      allow_any_instance_of(Api::V1::ReservationsController).to receive(:authenticate_user!)
      allow_any_instance_of(Api::V1::ReservationsController).to receive(:current_user).and_return(create(:user))
    end

    it 'makes a reservation' do
      post :create, params: { hotel_id: hotel.id, room_id: room.id, reservation: { check_in:, check_out: } }

      expect(response).to have_http_status :created
      expect(json_response).to include(
        'id' => be_present,
        'room_id' => room.id,
        'user_id' => be_present
      )
    end

    it 'returns an error if the room is not found' do
      post :create, params: { hotel_id: hotel.id, room_id: 'invalid', reservation: { check_in:, check_out: } }

      expect(response).to have_http_status :not_found
      expect(json_response).to eq({ 'error' => 'Room not found' })
    end

    it 'return an error if room is not available' do
      allow_any_instance_of(Room).to receive(:available?).and_return(false)
      post :create, params: { hotel_id: hotel.id, room_id: room.id, reservation: { check_in:, check_out: } }

      expect(response).to have_http_status :unprocessable_entity
      expect(json_response).to eq({ 'error' => 'Room is not available for the selected dates' })
    end
  end
end

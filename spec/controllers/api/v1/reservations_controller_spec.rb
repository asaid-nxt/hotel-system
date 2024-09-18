require 'rails_helper'

RSpec.describe Api::V1::ReservationsController, type: :controller do
  describe 'POST #create' do
    let(:user) { create(:user) }
    let(:hotel) { create(:hotel) }
    let(:room) { create(:room, hotel:) }
    let(:check_in) { Date.today }
    let(:check_out) { Date.tomorrow }

    before do
      allow_any_instance_of(Api::V1::ReservationsController).to receive(:authenticate_user!)
      allow_any_instance_of(Api::V1::ReservationsController).to receive(:current_user).and_return(user)
    end

    describe 'GET #index' do
      let!(:past_reservation) { create(:reservation, check_in: Date.today - 3.days, check_out: Date.yesterday, user:) }
      let!(:current_reservation) { create(:reservation, check_in: Date.today, check_out: Date.tomorrow, user:) }
      let!(:future_reservation) { create(:reservation, check_in: Date.tomorrow, check_out: Date.today + 2.days, user:) }

      it 'returns serialized past, current and future reservations' do
        get :index

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

    describe 'POST #create' do
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
end

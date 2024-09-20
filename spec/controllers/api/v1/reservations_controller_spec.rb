require 'rails_helper'

RSpec.describe Api::V1::ReservationsController, type: :controller do
  let(:user) { create(:user) }
  let(:hotel) { create(:hotel) }
  let(:room) { create(:room, hotel:) }
  let(:check_in) { Date.today }
  let(:check_out) { Date.tomorrow }

  describe 'GET #index' do
    let!(:past_reservation) { create(:reservation, check_in: Date.today - 3.days, check_out: Date.yesterday, user:) }
    let!(:current_reservation) { create(:reservation, check_in: Date.today, check_out: Date.tomorrow, user:) }
    let!(:future_reservation) { create(:reservation, check_in: Date.tomorrow, check_out: Date.today + 2.days, user:) }

    before do
      allow_any_instance_of(described_class).to receive(:authenticate_user!)
      allow_any_instance_of(described_class).to receive(:current_user).and_return(user)
    end

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

  describe 'GET #all_reservations' do # rubocop:disable Metrics/BlockLength
    describe 'when admin is authenticated' do
      let(:admin) { create(:user, username: 'admin', role: 'admin') }

      before do
        allow_any_instance_of(described_class).to receive(:authenticate_admin!)
        allow_any_instance_of(described_class).to receive(:current_user).and_return(admin)
      end

      describe 'if there is reservations' do
        let!(:reservations) { create_list(:reservation, 3, user:) }

        it 'returns all reservations' do
          get :all_reservations
          expect(response).to have_http_status :ok
          expect(json_response.size).to eq(3)
        end
      end

      describe 'if there is no reservations' do
        it 'return an empty list' do
          get :all_reservations
          expect(response).to have_http_status :ok
          expect(json_response).to be_empty
        end
      end
    end

    describe 'when admin is not authenticated' do
      let!(:reservations) { create_list(:reservation, 3, user:) }

      it 'return an Unauthorized error' do
        get :all_reservations
        expect(response).to have_http_status :unauthorized
      end
    end
  end

  describe 'POST #create' do
    before do
      allow_any_instance_of(described_class).to receive(:authenticate_user!)
      allow_any_instance_of(described_class).to receive(:current_user).and_return(user)
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

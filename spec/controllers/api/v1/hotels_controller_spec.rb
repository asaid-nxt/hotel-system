require 'rails_helper'

RSpec.describe Api::V1::HotelsController, type: :controller do # rubocop:disable Metrics/BlockLength
  let(:admin) { create(:user, role: 'admin') }
  let!(:hotel) { create(:hotel) }
  let(:valid_attributes) { { name: 'hotel', location: 'Cairo', amenities: 'Pool' } }
  let(:invalid_attributes) { { name: '', location: '', amenities: '' } }

  before do
    allow_any_instance_of(described_class).to receive(:authenticate_admin!).and_return(true)
  end

  describe 'POST #create' do
    describe 'with valid params' do
      it 'creates a hotel' do
        expect do
          post(:create, params: { hotel: valid_attributes })
        end.to change(Hotel, :count).by(1)
      end

      it 'returns a Json response with the new hotel' do
        post :create, params: { hotel: valid_attributes }
        expect(response).to have_http_status :created
        expect(json_response['name']).to eq('hotel')
      end
    end

    describe 'with invalid attributes' do
      it "doesn't create a hotel" do
        expect do
          post(:create, params: { hotel: invalid_attributes })
        end.to change(Hotel, :count).by(0)
      end

      it 'returns an error' do
        post :create, params: { hotel: invalid_attributes }
        expect(response).to have_http_status :unprocessable_entity
        expect(json_response).to eq({ 'error' => ["Name can't be blank", "Location can't be blank"] })
      end
    end
  end

  describe 'PUT #update' do
    describe 'with valid attributes' do
      it 'updates the selected hotel' do
        put :update, params: { id: hotel.id, hotel: { name: 'updated hotel' } }
        hotel.reload
        expect(json_response['name']).to eq('updated hotel')
        expect(response).to have_http_status :ok
      end
    end

    describe 'with invalid attributes' do
      it 'returns an error' do
        put :update, params: { id: hotel.id, hotel: { name: '' } }
        expect(json_response).to eq({ 'error' => ["Name can't be blank"] })
        expect(response).to have_http_status :unprocessable_entity
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'deletes the hotel' do
      expect do
        delete :destroy, params: { id: hotel.id }
      end.to change(Hotel, :count).by(-1)
      expect(response).to have_http_status :no_content
    end
  end
end

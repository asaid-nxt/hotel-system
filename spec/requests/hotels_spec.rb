require 'rails_helper'

RSpec.describe 'Hotels Api', type: :request do
  let(:admin) { create(:user, role: 'admin') }
  let(:user) { create(:user, username: 'user2') }
  let(:jwt_token) { admin.generate_jwt }
  let(:headers) { { 'Authorization' => jwt_token } }
  let(:user_headers) { { 'Authorization' => user.generate_jwt } }
  let!(:hotel) { create(:hotel) }
  let(:valid_attributes) { { name: 'hotel', location: 'Cairo', amenities: 'Pool' } }
  let(:invalid_attributes) { { name: '', location: '', amenities: '' } }

  describe 'POST /api/v1/hotels' do
    describe 'when admin is authenticated' do
      context 'with valid attributes' do
        before do
          post '/api/v1/hotels', params: { hotel: valid_attributes }, headers:
        end

        it 'creates a hotel' do
          expect(response).to have_http_status :created
          expect(json_response['name']).to eq('hotel')
        end
      end

      context 'with invalid attributes' do
        before do
          post '/api/v1/hotels', params: { hotel: invalid_attributes }, headers:
        end

        it 'returns an error' do
          expect(response).to have_http_status :unprocessable_entity
          expect(json_response).to eq({ 'error' => ["Name can't be blank", "Location can't be blank"] })
        end
      end
    end

    describe 'when user is authenticated' do
      before do
        post '/api/v1/hotels', params: { hotel: valid_attributes }, headers: user_headers
      end

      it 'returns Unauthorized error' do
        expect(response).to have_http_status :unauthorized
        expect(json_response).to eq({ 'error' => 'Unauthorized' })
      end
    end

    describe 'when there is no authentication' do
      it 'return unauthorized error' do
        post '/api/v1/hotels', params: { hotel: valid_attributes }
        expect(response).to have_http_status :unauthorized
        expect(json_response).to eq({ 'error' => 'Unauthorized' })
      end
    end
  end

  describe 'PUT /api/v1/hotels/:hotel_id' do
    describe 'when hotel exists' do
      context 'with valid attributes' do
        before do
          put "/api/v1/hotels/#{hotel.id}", params: { hotel: { name: 'updated hotel' } }, headers:
        end

        it 'updates the hotel' do
          expect(response).to have_http_status :ok
          expect(json_response['name']).to eq('updated hotel')
        end
      end

      context 'with invalid attributes' do
        before do
          put "/api/v1/hotels/#{hotel.id}", params: { hotel: { name: '' } }, headers:
        end

        it 'returns an error' do
          expect(json_response).to eq({ 'error' => ["Name can't be blank"] })
          expect(response).to have_http_status :unprocessable_entity
        end
      end
    end

    describe "when hotel doesn't exist" do
      before do
        put '/api/v1/hotels/invalid', params: { hotel: { name: 'updated hotel' } }, headers:
      end

      it 'returns not_found error' do
        expect(response).to have_http_status :not_found
        expect(json_response).to eq({ 'error' => 'Hotel not found' })
      end
    end
  end

  describe 'DELETE /api/v1/hotels/:hotel_id' do
    describe 'when hotel exists' do
      before do
        delete "/api/v1/hotels/#{hotel.id}", headers:
      end

      it 'deletes the hotel' do
        expect(response).to have_http_status :no_content
      end
    end

    describe 'when hotel does not exist' do
      before do
        delete '/api/v1/hotels/invalid', headers:
      end

      it 'return not found error' do
        expect(response).to have_http_status :not_found
        expect(json_response).to eq({ 'error' => 'Hotel not found' })
      end
    end

    describe 'when user is not authenticated' do
      before do
        delete "/api/v1/hotels/#{hotel.id}"
      end

      it 'return Unauthorized error' do
        expect(response).to have_http_status :unauthorized
        expect(json_response).to eq({ 'error' => 'Unauthorized' })
      end
    end
  end
end

require 'rails_helper'

RSpec.describe Api::V1::SessionsController, type: :controller do
  describe 'POST #create' do
    let(:user) { create(:user, username: 'testuser', password: 'password123') }

    context 'when the credentials are correct' do
      it 'returns a JWT token' do
        post :create, params: { username: user.username, password: 'password123' }

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['token']).to be_present
      end
    end

    context 'when the username is incorrect' do
      it 'returns an unauthorized status' do
        post :create, params: { username: 'wrongusername', password: 'password123' }

        expect(response).to have_http_status(:unauthorized)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Invalid username or password')
      end
    end

    context 'when the password is incorrect' do
      it 'returns an unauthorized status' do
        post :create, params: { username: user.username, password: 'wrongpassword' }

        expect(response).to have_http_status(:unauthorized)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Invalid username or password')
      end
    end

    context 'when the username and password are missing' do
      it 'returns an unauthorized status' do
        post :create, params: {}

        expect(response).to have_http_status(:unauthorized)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Invalid username or password')
      end
    end
  end
end

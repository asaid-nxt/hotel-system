require 'rails_helper'

RSpec.describe 'Sessions API', type: :request do
  describe 'POST /api/v1/login' do
    let(:user) { create(:user, password: 'password123') }

    context 'with valid credentials' do
      it 'returns a JWT token and status ok' do
        post '/api/v1/login', params: { username: user.username, password: 'password123' }

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response).to have_key('token')
      end
    end

    context 'with invalid username' do
      it 'returns an unauthorized status' do
        post '/api/v1/login', params: { username: 'wrongusername', password: 'password123' }

        expect(response).to have_http_status(:unauthorized)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Invalid username or password')
      end
    end

    context 'with invalid password' do
      it 'returns an unauthorized status' do
        post '/api/v1/login', params: { username: user.username, password: 'wrongpassword' }

        expect(response).to have_http_status(:unauthorized)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Invalid username or password')
      end
    end
  end
end

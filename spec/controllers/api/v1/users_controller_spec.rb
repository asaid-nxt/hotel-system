# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::UsersController, type: :controller do
  describe 'POST #create' do
    let(:valid_attributes) do
      { username: 'testuser', password: 'password', password_confirmation: 'password' }
    end

    let(:invalid_attributes) do
      { username: '', password: 'short', password_confirmation: 'different' }
    end

    context 'with valid parameters' do
      it 'creates a new user' do
        expect {
          post :create, params: { user: valid_attributes }
        }.to change(User, :count).by(1)
      end

      it 'returns a created status and a JWT token' do
        allow_any_instance_of(User).to receive(:generate_jwt).and_return('fake-jwt-token')

        post :create, params: { user: valid_attributes }

        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)['token']).to eq('fake-jwt-token')
        expect(JSON.parse(response.body)['user']['username']).to eq('testuser')
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new user' do
        expect {
          post :create, params: { user: invalid_attributes }
        }.not_to change(User, :count)
      end

      it 'returns unprocessable entity status with error messages' do
        post :create, params: { user: invalid_attributes }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['errors']).to include("Username can't be blank",
                                                               'Password is too short (minimum is 6 characters)')
      end
    end
  end
end

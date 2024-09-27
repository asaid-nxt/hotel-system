# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::UsersController, type: :controller do # rubocop:disable Metrics/BlockLength
  describe 'POST #create' do # rubocop:disable Metrics/BlockLength
    let(:valid_attributes) do {
      username: 'testuser',
      password: 'password',
      password_confirmation: 'password',
      first_name: 'harry',
      last_name: 'kane',
      preferences: 'Gym, Pool',
      image: fixture_file_upload(Rails.root.join('spec', 'fixtures', 'files', 'avatar.jpg'), 'image/jpg')
    }
    end

    let(:invalid_attributes) do
      { username: '', password: 'short', password_confirmation: 'different' }
    end

    let(:admin_attributes) do
      { username: 'adminuser', password: 'password', password_confirmation: 'password', role: 'admin' }
    end

    context 'with valid parameters' do
      it 'creates a new user' do
        expect do
          post :create, params: { user: valid_attributes }
        end.to change(User, :count).by(1)
      end

      it 'returns a created status and a JWT token' do
        allow_any_instance_of(User).to receive(:generate_jwt).and_return('fake-jwt-token')

        post :create, params: { user: valid_attributes }

        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)['token']).to eq('fake-jwt-token')
        expect(JSON.parse(response.body)['user']['username']).to eq('testuser')
        expect(json_response['user']['image_url']).to start_with('/rails/active_storage')
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new user' do
        expect do
          post :create, params: { user: invalid_attributes }
        end.not_to change(User, :count)
      end

      it 'returns unprocessable entity status with error messages' do
        post :create, params: { user: invalid_attributes }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['errors']).to include("Username can't be blank",
                                                               'Password is too short (minimum is 6 characters)')
      end
    end

    context 'when creating an admin user' do
      it 'creates a new admin user with role 1' do
        expect do
          post :create, params: { user: admin_attributes }
        end.to change(User, :count).by(1)

        user = User.last
        expect(user.role).to eq('admin')
      end
    end
  end
end

# spec/controllers/application_controller_spec.rb
require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  controller do
    before_action :authenticate_admin!, only: [:admin_action]
    before_action :authenticate_user!, only: [:user_action]

    def user_action
      render json: { message: 'Success for user' }, status: :ok
    end

    def admin_action
      render json: { message: 'Success for admin' }, status: :ok
    end
  end

  before do
    routes.draw do
      get 'user_action' => 'anonymous#user_action'
      get 'admin_action' => 'anonymous#admin_action'
    end
  end

  let(:user) { create(:user, role: 0) }
  let(:admin) { create(:user, role: 1) }
  let(:user_token) { JwtService.encode(user_id: user.id) }
  let(:admin_token) { JwtService.encode(user_id: admin.id) }
  let(:invalid_token) { 'invalid_token' }

  describe 'authenticate_request' do
    it 'allows access with valid user JWT token' do
      request.headers['Authorization'] = user_token
      get :user_action
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Success for user')
    end

    it 'returns unauthorized with invalid JWT token' do
      request.headers['Authorization'] = invalid_token
      get :user_action
      expect(response).to have_http_status(:unauthorized)
      expect(response.body).to include('Unauthorized')
    end
  end

  describe 'authenticate_admin!' do
    it 'allows access to admin with valid JWT token' do
      request.headers['Authorization'] = admin_token
      get :admin_action
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Success for admin')
    end

    it 'returns unauthorized if the user is not an admin' do
      request.headers['Authorization'] = user_token
      get :admin_action
      expect(response).to have_http_status(:unauthorized)
      expect(response.body).to include('Unauthorized')
    end

    it 'returns unauthorized with invalid JWT token for admin action' do
      request.headers['Authorization'] = invalid_token
      get :admin_action
      expect(response).to have_http_status(:unauthorized)
      expect(response.body).to include('Unauthorized')
    end
  end
end

require 'rails_helper'

RSpec.describe 'Users API', type: :request do
  describe 'POST api/v1/users' do
    let(:valid_attributes) { attributes_for(:user) }
    let(:invalid_attributes) { valid_attributes.merge(username: '') }

    context 'when request is valid' do
      it 'creates a user and return a JWT token' do
        post '/api/v1/users', params: { user: valid_attributes }
        json_response = JSON.parse(response.body)

        expect(response).to have_http_status :created
        expect(json_response['token']).not_to be_nil
        expect(json_response['user']['username']).to eq('test')
      end
    end

    context 'when request is not valid' do
      it "doesn't create a user and return erros" do
        post '/api/v1/users', params: { user: invalid_attributes }
        json_response = JSON.parse(response.body)

        expect(response).to have_http_status :unprocessable_entity
        expect(json_response['errors']).to include("Username can't be blank")
      end
    end
  end
end

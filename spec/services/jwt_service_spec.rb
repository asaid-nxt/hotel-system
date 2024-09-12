# frozen_string_literal: true

require 'rails_helper'
require 'jwt'

RSpec.describe JwtService, type: :service do
  let(:payload) { { user_id: 1 } }
  let(:secret_key) { Rails.application.credentials.secret_key_base.to_s }

  describe '.encode' do
    it 'encodes a payload into a JWT token' do
      token = JwtService.encode(payload)
      decoded_token = JWT.decode(token, secret_key)[0]
      expect(decoded_token).to eq(payload.stringify_keys)
    end
  end

  describe '.decode' do
    context 'when token is valid' do
      it 'decodes the token into a payload' do
        token = JwtService.encode(payload)
        decoded_payload = JwtService.decode(token)
        expect(decoded_payload).to eq(payload.with_indifferent_access)
      end
    end

    context 'when token is invalid' do
      it 'returns nil' do
        invalid_token = 'invalid.token.here'
        expect(JwtService.decode(invalid_token)).to be_nil
      end
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { create(:user) }

  describe 'Validations' do
    it 'is valid with valid attributes' do
      expect(user).to be_valid
    end

    it 'is not valid with no username' do
      user.username = nil
      expect(user).not_to be_valid
    end

    it 'is not valid if the username is not unique' do
      create(:user, username: 'test')
      user1 = build(:user, username: 'test')
      expect(user1).not_to be_valid
    end

    it 'is not valid with no password' do
      user.password = nil
      expect(user).not_to be_valid
    end

    it 'is not valid if password length is less than 6' do
      user.password = '123'
      expect(user).not_to be_valid
    end
  end
end

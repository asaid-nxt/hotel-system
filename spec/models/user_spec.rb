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

  describe 'Enums' do
    it 'defines the correct roles' do
      expect(User.roles.keys).to contain_exactly('user', 'admin')
    end

    it 'sets default role to user' do
      user = create(:user)
      expect(user.role).to eq('user')
    end

    it 'can set role to admin' do
      user = create(:user, role: :admin)
      expect(user.role).to eq('admin')
    end

    it 'returns true for admin? if the role is admin' do
      user = create(:user, role: :admin)
      expect(user.admin?).to be_truthy
    end

    it 'returns false for admin? if the role is user' do
      user = create(:user, role: :user)
      expect(user.admin?).to be_falsey
    end

    it 'returns true for user? if the role is user' do
      user = create(:user, role: :user)
      expect(user.user?).to be_truthy
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do # rubocop:disable Metrics/BlockLength
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

  describe 'associations' do
    it { should have_many(:reservations) }
  end

  describe '#generate_jwt' do
    it 'it calls JWTService to encode user_id' do
      expect(JwtService).to receive(:encode).with({ user_id: user.id }).and_return('token')
      token = user.generate_jwt

      expect(token).to eq('token')
    end
  end

  describe 'image attachment' do
    it 'attaches an image' do
      user.image.attach(io: File.open(Rails.root.join('spec/fixtures/files/avatar.jpg')),
                        filename: 'avatar.jpg', content_type: 'image/jpg')
      expect(user.image).to be_attached
    end
  end
end

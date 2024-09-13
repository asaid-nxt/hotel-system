require 'rails_helper'

RSpec.describe Room, type: :model do
  let(:hotel) { create(:hotel) }
  let(:room) { create(:room, hotel:) }

  describe 'Validation' do
    it 'is valid with valid attributes' do
      expect(room).to be_valid
    end

    it 'is not valid with no hotel' do
      room.hotel = nil
      expect(room).not_to be_valid
    end

    it 'is not valid with no number' do
      room.number = nil
      expect(room).not_to be_valid
    end

    it 'not valid with no capacity' do
      room.capacity = nil
      expect(room).not_to be_valid
    end

    it 'not valid with less than 1 capacity' do
      room.capacity = 0
      expect(room).not_to be_valid
    end
  end

  describe 'associations' do
    it { should belong_to(:hotel) }
    it { should have_many(:reservations).dependent(:destroy) }
  end
end

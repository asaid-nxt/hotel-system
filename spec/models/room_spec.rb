require 'rails_helper'

RSpec.describe Room, type: :model do # rubocop:disable Metrics/BlockLength
  describe 'Validation' do
    let(:hotel) { create(:hotel) }
    let(:room) { create(:room, hotel:) }

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

    it 'not vaild if data type is not integer' do
      room.capacity = 'n'
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

  describe '.available' do # rubocop:disable Metrics/BlockLength
    let!(:hotel) { create(:hotel) }
    let!(:available_room) { create(:room, hotel:) }
    let!(:unavailable_room) { create(:room, hotel:) }
    let(:user) { create(:user) }

    before do
      create(:reservation, room: unavailable_room, check_in: 1.day.from_now, check_out: 3.days.from_now, user:)
    end

    context 'when there are no reservations' do
      it 'returns all rooms for the given hotel' do
        check_in = 5.days.from_now
        check_out = 7.days.from_now

        rooms = Room.available(hotel.id, check_in, check_out)

        expect(rooms).to include(available_room)
        expect(rooms).to include(unavailable_room)
      end
    end

    context 'when reservations overlap with the check-in and check-out dates' do
      it 'returns only rooms that do not have overlapping reservations' do
        check_in = 2.days.from_now
        check_out = 4.days.from_now

        rooms = Room.available(hotel.id, check_in, check_out)

        expect(rooms).to include(available_room)
        expect(rooms).not_to include(unavailable_room)
      end
    end

    context 'when all rooms are reserved' do
      before do
        create(:reservation, room: available_room, check_in: 1.day.from_now, check_out: 3.days.from_now, user:)
      end

      it 'returns no rooms' do
        check_in = 1.day.from_now
        check_out = 2.days.from_now

        rooms = Room.available(hotel.id, check_in, check_out)

        expect(rooms).to be_empty
      end
    end
  end

  describe '.available?' do
    let(:hotel) { create(:hotel) }
    let(:room) { create(:room, hotel:) }
    let(:check_in) { Date.today }
    let(:check_out) { Date.tomorrow }

    it 'when room is available' do
      expect(room.available?(check_in, check_out)).to be_truthy
    end

    it 'when only check_in overlaps' do
      create(:reservation, room:, check_in:, check_out: Date.today + 3.days)
      expect(room.available?(check_in, check_out)).to be_falsy
    end

    it 'when only check_out overlaps' do
      create(:reservation, room:, check_in: Date.today - 2.days, check_out:)
      expect(room.available?(check_in, check_out)).to be_falsy
    end

    it 'when room is not available' do
      create(:reservation, room:, check_in:, check_out:)
      expect(room.available?(check_in, check_out)).to be_falsy
    end
  end
end

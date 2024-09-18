require 'rails_helper'

RSpec.describe Reservation, type: :model do
  let(:user) { create(:user) }

  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:room) }
  end

  describe 'validations' do
    let(:reservation) { create(:reservation) }
    it { should validate_presence_of(:check_in) }
    it { should validate_presence_of(:check_out) }

    context 'check_dates validation' do
      it 'is valid when check_out is after check_in' do
        reservation.check_in = Date.today
        reservation.check_out = Date.tomorrow
        expect(reservation).to be_valid
      end

      it 'is invalid when check_out is before or equal to check_in' do
        reservation.check_in = Date.today
        reservation.check_out = Date.today
        expect(reservation).not_to be_valid
        expect(reservation.errors[:check_out]).to include('must be after check-in')
      end
    end
  end

  describe 'reservations scopes' do
    let(:past_resrevation) { create(:reservation, check_in: Date.today - 3.days, check_out: Date.yesterday, user:) }
    let(:current_resrevation) { create(:reservation, check_in: Date.today, check_out: Date.tomorrow, user:) }
    let(:future_resrevation) { create(:reservation, check_in: Date.tomorrow, check_out: Date.today + 2.days, user:) }

    describe '.past' do
      it 'returns past reservations' do
        past = Reservation.past
        expect(past).to include(past_resrevation)
        expect(past).not_to include(current_resrevation, future_resrevation)
      end

      it 'returns current reservations' do
        current = Reservation.current
        expect(current).to include(current_resrevation)
        expect(current).not_to include(past_resrevation, future_resrevation)
      end

      it 'returns future reservations' do
        future = Reservation.future
        expect(future).to include(future_resrevation)
        expect(future).not_to include(past_resrevation, current_resrevation)
      end
    end
  end
end

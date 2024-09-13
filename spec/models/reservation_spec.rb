require 'rails_helper'

RSpec.describe Reservation, type: :model do
  let(:reservation) { create(:reservation) }

  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:room) }
  end

  describe 'validations' do
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
end

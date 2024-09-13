require 'rails_helper'

RSpec.describe Hotel, type: :model do
  describe 'Validations' do
    let(:hotel) { create(:hotel) }

    it 'is valid with valide attributes' do
      expect(hotel).to be_valid
    end

    it 'is not valid with no hotel name' do
      hotel.name = nil
      expect(hotel).not_to be_valid
    end

    it 'is not valid with no location' do
      hotel.location = nil
      expect(hotel).not_to be_valid
    end
  end

  describe 'associations' do
    it { should have_many(:rooms).dependent(:destroy) }
  end
end

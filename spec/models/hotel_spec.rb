require 'rails_helper'

RSpec.describe Hotel, type: :model do
  let(:hotel) { create(:hotel) }
  describe 'Validations' do
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

  describe 'image attachment' do
    it 'attaches an image' do
      hotel.image.attach(io: File.open(Rails.root.join('spec/fixtures/files/hotel.jpg')),
                         filename: 'hotel.jpg', content_type: 'image/jpg')
      expect(hotel.image).to be_attached
    end
  end
end

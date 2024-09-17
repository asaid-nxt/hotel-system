require 'rails_helper'

RSpec.describe DateParser, type: :service do
  let(:check_in) { Date.today }
  let(:check_out) { Date.tomorrow }
  let(:params) { { check_in:, check_out: } }
  let(:result) { DateParser.parse_dates(params) }

  describe '.parse_dates' do
    context 'with valid dates' do
      it 'parses the data succesfully' do
        expect(result).to eq([check_in, check_out])
      end
    end

    context 'with invalid dates format' do
      let(:check_in) { 'invalid' }
      it 'return an error' do
        expect(result).to eq({ 'error': 'Invalid date format' })
      end
    end

    context 'with missing check_in date' do
      let(:check_in) {}
      it 'return an error' do
        expect(result).to eq({ 'error': 'check-in and check-out dates are required' })
      end
    end

  end
end

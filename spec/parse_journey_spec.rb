# frozen_string_literal: true

require_relative '../lib/parse_journeys'

RSpec.describe ParseJourneys do
  let(:parser) { described_class.new(response) }
  let(:response) do
    JSON.parse(File.read('spec/fixtures/journey_search_response.json'))
  end

  describe '#parse' do
    it 'should return a parsed journey data' do
      journey = parser.parse[1]
      fares = journey[:fares]

      expect(journey[:departure_station]).to eq('München Hbf')
      expect(journey[:departure_at]).to be_a DateTime
      expect(journey[:arrival_station]).to eq('Karlovac Central Bus Station')
      expect(journey[:arrival_at]).to be_a DateTime
      expect(journey[:service_agencies]).to eq(['ÖBB', 'Autotrans by Arriva', 'Westbahn'])
      expect(journey[:duration_in_minutes]).to eq 666
      expect(journey[:changeover]).to eq 3
      expect(journey[:products]).to eq(['train', 'bus', 'train'])
      expect(journey[:fares].count).to eq 10

      fare_names = fares.map { |fare| fare[:name] }
      expect(fare_names[0..3].count('WESTsuperpreis ticket')).to eq(4)
      expect(fare_names[4..8].count('Sparschiene')).to eq(5)
      expect(fare_names[9]).to eq('Autotrans by Arriva')

      fare_currencies = fares.map { |fare| fare[:currency] }
      expect(fare_currencies.count('EUR')).to eq(10)
      
      fare_comfort_classes = fares.map { |fare| fare[:comfort_class] }
      expect(fare_comfort_classes[0..2].count(2)).to eq(3)
      expect(fare_comfort_classes[3]).to eq(1)
      expect(fare_comfort_classes[4..5].count(2)).to eq(2)
      expect(fare_comfort_classes[6..8].count(1)).to eq(3)
      expect(fare_comfort_classes[9]).to eq(2)


      prices = ['3399','4189','3689','5889','7610','7960','9530','9880','11030','580']

      fares.each_with_index do |fare, i|
        expect(fare[:price_in_cents]).to eq(prices[i])
      end
    end
  end
end

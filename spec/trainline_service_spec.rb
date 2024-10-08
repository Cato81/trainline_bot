# frozen_string_literal: true

require 'webmock/rspec'
require_relative '../lib/trainline_service'

RSpec.describe TrainlineService do
  let(:trainline_service) { TrainlineService.new(from, to, departure_at) }
  let(:from) { 'Munich' }
  let(:to) { 'Karlovac' }
  let(:departure_at) { DateTime.now }
  let(:journey_search_path) { '/api/journey-search/' }
  let(:location_search_path) { '/api/locations-search/v2/search' }
  let(:journey_object) do
    JSON.parse(File.read('spec/fixtures/journey_search_response.json'))
  end
  let(:munich_locations_array) do
    JSON.parse(File.read('spec/fixtures/munich_location_response.json'))
  end
  let(:karlovac_locations_array) do
    JSON.parse(File.read('spec/fixtures/karlovac_location_response.json'))
  end
  let(:request_body) do
    {
      passengers: [],
      transitDefinitions:
      [
        {
          direction: "outward",
          origin: 'urn:trainline:generic:loc:7480',
          destination: 'urn:trainline:generic:loc:29587',
          journeyDate: {
            type: "departAfter",
            time: departure_at
          }
        }
      ],
      type: 'single',
      transportModes: [
        'mixed'
      ],
    }
  end

  describe '#call' do
    before do
      allow(ApiClient).to receive(:locations)
        .with(location_search_path, { searchTerm: from, locale: 'en-US' })
        .and_return(munich_locations_array)
      allow(ApiClient).to receive(:locations)
        .with(location_search_path, { searchTerm: to, locale: 'en-US' })
        .and_return(karlovac_locations_array)
    end

    context 'when there are journeys' do
      before do
        allow(ApiClient).to receive(:journeys)
          .with(journey_search_path, request_body)
          .and_return(journey_object)
      end
  
      it 'should return array with all parsed journey data' do
        journey_data = trainline_service.call
  
        expect(journey_data).to be_a(Array)
        expect(journey_data.count).to eq(3)
        expect(journey_data).to all(include(
          :departure_station, :departure_at, :arrival_station, :arrival_at, :service_agencies, 
          :duration_in_minutes, :changeover, :products, :fares
          ))
      end
    end

    context 'when there are no journeys' do
      let(:journey_object) do
        JSON.parse(File.read('spec/fixtures/journey_search_empty_response.json'))
      end

      before do
        allow(ApiClient).to receive(:journeys)
          .with(journey_search_path, request_body)
          .and_return(journey_object)
      end

      it 'should return empty array' do
        expect(trainline_service.call).to eq([])
      end
    end

    context 'when APIError was raised' do
      let(:logger_double) { instance_double(Logger) }
      before do
        allow(ApiClient).to receive(:journeys).and_raise(ApiClient::APIError.new("Status: 400 - No pass."))
        allow(trainline_service).to receive(:logger).and_return(logger_double)
        allow(logger_double).to receive(:error)
        allow(logger_double).to receive(:debug)
      end

      it 'should log an error message' do
        trainline_service.call
        
        expect(logger_double).to have_received(:error).with(/Status: 400 - No pass./)
      end
    end
  end
end

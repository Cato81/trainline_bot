# frozen_string_literal: true

require 'webmock/rspec'
require_relative '../lib/api_client'

RSpec.describe ApiClient do
  describe '.journeys' do
    let(:request_body) { { traveler: 'adventure'} }
    let(:url) { 'https://www.thetrainline.com/journeys' }
    
    context 'when response is success' do
      let(:response_body) { { train: 'happy' }.to_json }
      let(:httparty_object) do
        double('HTTParty::Response', code: 200, success?: true, parsed_response: JSON.parse(response_body))
      end

      before do
        allow(HTTParty).to receive(:post).and_return(httparty_object)
      end
      
      it 'should return expected journey data' do
        response = described_class.journeys('journeys', request_body)

        expect(response).to eq({ 'train' => 'happy' })
      end
    end

    context 'when response returns an error' do
      let(:response_body) { { error: 'no trains for you' }.to_json }
      let(:httparty_object) do
        double('HTTParty::Response', code: 400, success?: false, message: 'No pass', body: JSON.parse(response_body))
      end

      before do
        allow(HTTParty).to receive(:post).and_return(httparty_object)
      end

      it 'should raise APIError' do
        expect { 
          described_class.journeys('journeys', request_body) 
        }.to raise_error(ApiClient::APIError, /Status: 400 - No pass.\n Response: {\"error\"=>\"no trains for you\"/)
      end
    end
  end

  describe '.locations' do
    let(:url) { 'https://www.thetrainline.com/locations' }
    let(:query) { {find: 'park'} }  
    
    before do
      allow(HTTParty).to receive(:get).and_return(httparty_object)
    end

    context 'when response is success' do
      let(:response_body) { { 'place' => 'Park' }.to_json }
      let(:httparty_object) do
        double('HTTParty::Response', code: 200, success?: true, parsed_response: JSON.parse(response_body))
      end

      it 'should return expected location data' do
        response = described_class.locations('locations', query)

        expect(response).to eq({ 'place' => 'Park' })
      end
    end

    context 'when response returns an error' do
      let(:response_body) { { error: 'No way' }.to_json }
      let(:httparty_object) do
        double('HTTParty::Response', code: 404, success?: false, message: 'There there', body: JSON.parse(response_body ))
      end

      it 'should raise APIError' do
        expect { 
          described_class.locations('locations', query) 
        }.to raise_error(ApiClient::APIError, /Status: 404 - There there.\n Response: {\"error\"=>\"No way\"/)
      end
    end
  end
end

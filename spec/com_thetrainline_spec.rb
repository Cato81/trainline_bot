# frozen_string_literal: true

require_relative '../lib/com_thetrainline'

RSpec.describe ComTheTrainline do
  let(:from) { 'Munich' }
  let(:to) { 'Karlovac' }
  let(:departure_at) { DateTime.now }
  let(:trainline_service) { instance_double(TrainlineService) }

  before do
    allow(TrainlineService).to receive(:new).with(from, to, departure_at).and_return(trainline_service)
    allow(trainline_service).to receive(:call)
  end
  
  describe '.find' do
    it 'should call TrainlineService' do
      ComTheTrainline.find(from, to, departure_at)

      expect(trainline_service).to have_received(:call)
      expect(TrainlineService).to have_received(:new).with(from, to, departure_at)
    end
  end
end

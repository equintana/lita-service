require 'spec_helper'

describe Lita::Interactors::CreateService do
  let(:interactor) { described_class.new(handler, data) }
  let(:handler) { double('handler') }
  let(:data) { ['create new-service', name, 2000] }
  let(:name) { 'new-service' }
  let(:service) do
    { name: name,
      value: 2000.0,
      state: 'active',
      customers: [] }
  end
  let(:fake_repository) { double('redis-repository') }

  before do
    allow(interactor).to receive(:repository).and_return(fake_repository)
  end

  describe '#perform' do
    describe 'when the service does not exist' do
      before do
        allow(fake_repository).to receive(:exists?).with(name).and_return(false)
        allow(fake_repository).to receive(:add).with(service)
      end

      it 'creates the service' do
        interactor.perform
        expect(interactor.success?).to eq true
        expect(interactor.message).to eq service
      end
    end

    describe 'when service exists' do
      let(:error_message) { 'A service called new-service exist already' }
      before do
        allow(fake_repository).to receive(:exists?).with(name).and_return(true)
      end

      it 'does not create the service' do
        interactor.perform
        expect(interactor.success?).to eq false
        expect(interactor.error).to eq error_message
      end
    end
  end
end

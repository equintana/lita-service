# frozen_string_literal: false
require 'spec_helper'

describe Lita::Interactors::ShowService do
  let(:interactor) { described_class.new(handler, data) }
  let(:handler) { double('handler') }
  let(:data) { ['show awesome-service', name] }
  let(:name) { 'awesome-service' }
  let(:fake_repository) { double('redis-repository') }

  before do
    allow(interactor).to receive(:repository).and_return(fake_repository)
  end

  describe '#perform' do
    describe 'when the service does not exist' do
      let(:error_message) do
        I18n.t('lita.handlers.service.errors.not_found', service_name: name)
      end

      before do
        allow(fake_repository).to receive(:exists?).with(name).and_return(false)
      end

      it 'shows an error message' do
        interactor.perform
        expect(interactor.success?).to eq false
        expect(interactor.error).to eq error_message
      end
    end

    describe 'when service exists' do
      let(:service) do
        { name: name,
          value: 2000,
          state: 'active',
          customers: { erlinis: { quantity: 1, value: 2000 } } }
      end

      before do
        allow(fake_repository).to receive(:exists?).with(name).and_return(true)
        allow(fake_repository).to receive(:find).with(name).and_return(service)
      end

      it 'returns the service' do
        interactor.perform
        expect(interactor.success?).to eq true
        expect(interactor.message).to eq service
      end
    end
  end
end

# frozen_string_literal: false
require 'spec_helper'

describe Lita::Interactors::CreateService do
  let(:interactor) { described_class.new(handler, data) }
  let(:handler) { double('handler') }
  let(:data) { ['create new-service', name, 2000] }
  let(:name) { 'new-service' }
  let(:fake_repository) { double('redis-repository') }

  before do
    allow(interactor).to receive(:repository).and_return(fake_repository)
  end

  describe '#perform' do
    describe 'when the service does not exist' do
      let(:service) do
        { name: name,
          value: 2000,
          state: 'active',
          customers: {} }
      end

      before do
        allow(fake_repository).to receive(:exists?).with(name).and_return(false)
      end

      it 'creates the service' do
        expect(fake_repository).to receive(:add).with(service)
        interactor.perform
        expect(interactor.success?).to eq true
        expect(interactor.message).to eq service
      end
    end

    describe 'when service exists' do
      let(:error_message) do
        I18n.t('lita.handlers.service.errors.duplicated', service_name: name)
      end

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

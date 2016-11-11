# frozen_string_literal: false
require 'spec_helper'

describe Lita::Interactors::DeleteService do
  let(:interactor) { described_class.new(handler, data) }
  let(:handler) { double('handler') }
  let(:data) { ['delete awesome-service', 'delete', name] }
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

      it 'shows error message' do
        interactor.perform
        expect(interactor.success?).to eq false
        expect(interactor.error).to eq error_message
      end
    end

    describe 'when service exists' do
      let(:success_message) do
        I18n.t('lita.handlers.service.delete.success', service_name: name)
      end

      before do
        allow(fake_repository).to receive(:exists?).with(name).and_return(true)
      end

      it 'deletes the service' do
        expect(fake_repository).to receive(:delete).with(name).and_return(true)
        interactor.perform
        expect(interactor.success?).to eq true
        expect(interactor.message).to eq success_message
      end
    end
  end
end

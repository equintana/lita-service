# frozen_string_literal: false
require 'spec_helper'

describe Lita::Interactors::AddAll do
  let(:data) { ['the-service add all', name, 'add', nil] }
  let(:lita_user) { OpenStruct.new(id: '123', name: 'the-user') }
  let(:interactor) { described_class.new(handler, data, lita_user) }
  let(:handler) { double('handler') }
  let(:fake_repository) { double('redis-repository') }
  let(:fake_time) { Time.parse('2016-12-23T19:51:57.918Z') }

  before do
    allow(interactor).to receive(:repository).and_return(fake_repository)
  end

  describe '#perform' do
    let(:name) { 'the-service' }

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
          customers: {
            erlinis: { quantity: 3, value: 2000 },
            khal: { quantity: 2, value: 2000 }
          } }
      end

      let(:service_quantities_updated) do
        { name: name,
          value: 2000,
          state: 'active',
          customers: {
            erlinis: {
              quantity: (3 + quantity),
              value: 2000,
              updated_at: fake_time,
              updated_by: 'the-user'
            },
            khal: {
              quantity: (2 + quantity),
              value: 2000,
              updated_at: fake_time,
              updated_by: 'the-user'
            }
          } }
      end

      let(:success_message) do
        I18n.t('lita.handlers.service.add_all.success',
               quantity: quantity)
      end

      before do
        allow(fake_repository).to receive(:exists?).with(name).and_return(true)
        allow(fake_repository).to receive(:find).with(name).and_return(service)
        allow(Time).to receive(:now).and_return(fake_time)
      end

      describe 'with a given quantity' do
        let(:data) { ['the-service add all 3', name, 'add', '3'] }
        let(:quantity) { 3 }

        it 'increments the quantity to all' do
          expect(fake_repository).to receive(:update).with(service_quantities_updated)
          interactor.perform
          expect(interactor.success?).to eq true
          expect(interactor.message).to eq success_message
        end
      end

      describe 'with a negative quantity' do
        let(:data) { ['the-service add all -1', name, 'add', '-1'] }
        let(:quantity) { -1 }

        it 'decrease the quantity to all' do
          expect(fake_repository).to receive(:update).with(service_quantities_updated)
          interactor.perform
          expect(interactor.success?).to eq true
          expect(interactor.message).to eq success_message
        end
      end

      describe 'without a quantity' do
        let(:quantity) { 1 }

        it 'increments the quantity to all with default value' do
          expect(fake_repository).to receive(:update).with(service_quantities_updated)
          interactor.perform
          expect(interactor.success?).to eq true
          expect(interactor.message).to eq success_message
        end
      end
    end
  end
end

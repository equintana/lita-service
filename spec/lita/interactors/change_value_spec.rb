# frozen_string_literal: false
require 'spec_helper'

describe Lita::Interactors::ChangeValue do
  let(:data) { ['the-service value @erlinis 2000', name, '@erlinis', '2000'] }
  let(:interactor) { described_class.new(handler, data) }
  let(:handler) { double('handler') }
  let(:fake_repository) { double('redis-repository') }

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
      describe 'when customer is not in the service' do
        let(:service) do
          { name: name,
            value: 2000,
            state: 'active',
            customers: { khal: { quantity: 1, value: 2000 } } }
        end

        let(:error_message) do
          I18n.t('lita.handlers.service.customer.not_found',
                 service_name: name, customer_name: 'erlinis')
        end

        before do
          allow(fake_repository).to receive(:exists?).with(name).and_return(true)
          allow(fake_repository).to receive(:find).with(name).and_return(service)
        end

        it 'shows an error message' do
          interactor.perform
          expect(interactor.success?).to eq false
          expect(interactor.error).to eq error_message
        end
      end

      describe 'when customer is in service' do
        let(:service) do
          { name: name,
            value: 2000,
            state: 'active',
            customers: { erlinis: { quantity: 1, value: 1000 } } }
        end

        let(:service_customer_updated) do
          { name: name,
            value: 2000,
            state: 'active',
            customers: { erlinis: { quantity: 1, value: 2000 } } }
        end

        let(:success_message) do
          I18n.t('lita.handlers.service.set_value.success',
                 customer_name: 'erlinis',
                 customer_value: customer_value,
                 old_value: 1000)
        end

        before do
          allow(fake_repository).to receive(:exists?).with(name).and_return(true)
          allow(fake_repository).to receive(:find).with(name).and_return(service)
          allow(fake_repository).to receive(:update).with(service_customer_updated)
        end

        describe 'updates customer value' do
          let(:customer_value) { 2000 }

          it 'update users value' do
            interactor.perform
            expect(interactor.success?).to eq true
            expect(interactor.message).to eq success_message
          end
        end
      end
    end
  end
end

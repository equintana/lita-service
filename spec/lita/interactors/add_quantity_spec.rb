# frozen_string_literal: false
require 'spec_helper'

describe Lita::Interactors::AddQuantity do
  let(:data) { ['the-service add @erlinis', name, 'add', '@erlinis', nil] }
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
        let(:data) { ['the-service add erlinis 1', name, 'add', 'erlinis', 1] }

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
            customers: { erlinis: { quantity: 3, value: 2000 } } }
        end

        let(:service_customer_updated) do
          { name: name,
            value: 2000,
            state: 'active',
            customers: {
              erlinis: { quantity: customer_quantity, value: 2000 }
            } }
        end

        let(:success_message) do
          I18n.t('lita.handlers.service.add.success',
                 customer_name: 'erlinis',
                 customer_quantity: customer_quantity,
                 quantity: quantity)
        end

        before do
          allow(fake_repository).to receive(:exists?).with(name).and_return(true)
          allow(fake_repository).to receive(:find).with(name).and_return(service)
          allow(fake_repository).to receive(:update).with(service_customer_updated)
        end

        describe 'with a given quantity' do
          let(:data) { ['the-service add @erlinis 3', name, 'add', '@erlinis', '3'] }
          let(:customer_quantity) { 6 }
          let(:quantity) { 3 }

          it 'increments the customer quantity' do
            interactor.perform
            expect(interactor.success?).to eq true
            expect(interactor.message).to eq success_message
          end
        end

        describe 'with a negative quantity' do
          let(:data) { ['the-service add @erlinis -1', name, 'add', '@erlinis', '-1'] }
          let(:customer_quantity) { 2 }
          let(:quantity) { -1 }

          it 'decrease the customer quantity' do
            interactor.perform
            expect(interactor.success?).to eq true
            expect(interactor.message).to eq success_message
          end
        end

        describe 'without a quantity' do
          let(:data) { ['the-service add @erlinis', name, 'add', '@erlinis', nil] }
          let(:customer_quantity) { 4 }
          let(:quantity) { 1 }

          it 'increments the customer quantity with default value' do
            interactor.perform
            expect(interactor.success?).to eq true
            expect(interactor.message).to eq success_message
          end
        end
      end
    end
  end
end

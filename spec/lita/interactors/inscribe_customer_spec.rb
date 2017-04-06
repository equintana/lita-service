# frozen_string_literal: false
require 'spec_helper'

describe Lita::Interactors::InscribeCustomer do
  let(:data) { ['the-service inscribe @erlinis', name, '@erlinis', nil] }
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
      describe 'when customer already in service' do
        let(:service) do
          {
            name: name,
            value: 2000,
            state: 'active',
            customers: {
              erlinis: {
                quantity: 1,
                value: 2000,
                updated_at: '',
                updated_by: ''
              }
            }
          }
        end

        let(:error_message) do
          I18n.t('lita.handlers.service.customer.duplicated',
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

      describe 'when customer not in service' do
        let(:service) do
          { name: name,
            value: 2000,
            state: 'active',
            customers: {} }
        end

        let(:success_message) do
          I18n.t('lita.handlers.service.inscribe.success',
                 service_name: name, customer_name: 'erlinis')
        end

        before do
          allow(fake_repository).to receive(:exists?).with(name).and_return(true)
          allow(fake_repository).to receive(:find).with(name).and_return(service)
        end

        describe 'with custom service value' do
          let(:data) do
            ['the-service inscribe @erlinis 3000', name, '@erlinis', '3000']
          end

          let(:service_with_customer) do
            { name: name,
              value: 2000,
              state: 'active',
              customers: {
                erlinis: { quantity: 0, value: 3000, updated_at: '', updated_by: '' }
              } }
          end

          it 'adds the customer setting the custom value' do
            expect(fake_repository).to receive(:update).with(service_with_customer)
            interactor.perform
            expect(interactor.success?).to eq true
            expect(interactor.message).to eq success_message
          end
        end

        describe 'without custom service value' do
          let(:service_with_customer) do
            {
              name: name,
              value: 2000,
              state: 'active',
              customers: {
                erlinis: {
                  quantity: 0,
                  value: 2000,
                  updated_at: '',
                  updated_by: ''
                }
              }
            }
          end

          it 'adds the customer setting the custom value' do
            expect(fake_repository).to receive(:update).with(service_with_customer)
            interactor.perform
            expect(interactor.success?).to eq true
            expect(interactor.message).to eq success_message
          end
        end
      end
    end
  end
end

# frozen_string_literal: false
require 'spec_helper'

describe Lita::Interactors::ResetQuantity do
  let(:data) { ['service the-service reset @erlinis', name, 'erlinis'] }
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
        let(:success_message) do
          I18n.t('lita.handlers.service.reset.success', customer_name: 'erlinis')
        end

        before do
          service = {
            name: name,
            value: 2000,
            state: 'active',
            customers: {
              erlinis: { quantity: 3, value: 2000 }
            }
          }

          service_customer_updated = {
            name: name,
            value: 2000,
            state: 'active',
            customers: {
              erlinis: {
                quantity: 0,
                value: 2000,
                updated_at: fake_time,
                updated_by: 'the-user'
              }
            }
          }

          allow(fake_repository).to receive(:exists?).with(name).and_return(true)
          allow(fake_repository).to receive(:find).with(name).and_return(service)
          allow(fake_repository).to receive(:update).with(service_customer_updated)
          allow(Time).to receive(:now).and_return(fake_time)
        end

        it 'reset the customer quantity to zero' do
          interactor.perform
          expect(interactor.success?).to eq true
          expect(interactor.message).to eq success_message
        end
      end
    end
  end
end

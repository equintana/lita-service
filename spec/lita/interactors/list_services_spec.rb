# frozen_string_literal: false
require 'spec_helper'

describe Lita::Interactors::ListServices do
  let(:interactor) { described_class.new(handler, data) }
  let(:handler) { double('handler') }
  let(:data) { ['list'] }
  let(:fake_repository) { double('redis-repository') }

  before do
    allow(interactor).to receive(:repository).and_return(fake_repository)
  end

  describe '#perform' do
    describe 'without services' do
      it 'returns an empty list' do
        expect(fake_repository).to receive(:all).and_return([])
        interactor.perform
        expect(interactor.success?).to eq true
        expect(interactor.message).to eq []
      end
    end

    describe 'with services' do
      let(:services) do
        [
          { name: 'service_one',
            value: 2000,
            state: 'active',
            customers: {
              jhon: { quantity: 2, value: 2000 },
              arya: { quantity: 2, value: 2000 }
            } },
          { name: 'service_two',
            value: 2000,
            state: 'active',
            customers: {
              khal: { quantity: 1, value: 2000 }
            } }
        ]
      end

      it 'returns a list of services' do
        expect(fake_repository).to receive(:all).and_return(services)
        interactor.perform
        expect(interactor.success?).to eq true
        expect(interactor.message).to eq services
      end
    end
  end
end

# frozen_string_literal: true
require 'spec_helper'

describe Lita::Repositories::Redis do
  let(:redis) { double('redis') }
  let(:repository) { described_class.new(redis) }

  describe 'methods' do
    describe 'exists?' do
      before do
        allow(redis).to receive(:exists).with('key').and_return(false)
      end
      it { expect(repository.exists?('key')).to eq false }
    end

    describe 'all' do
      let(:resources) { %w(key1 key2) }

      before do
        allow(redis).to receive(:keys)
          .and_return(resources)
      end
      it { expect(repository.all).to eq resources }
    end

    describe 'add' do
      let(:resource) do
        { name: 'key', attr: '1' }
      end
      before do
        allow(redis).to receive(:set)
          .with('key', MultiJson.dump(resource))
          .and_return('OK')
      end
      it { expect(repository.add(resource)).to eq 'OK' }
    end

    describe 'update' do
      let(:resource) do
        { name: 'key', attr: '1' }
      end
      before do
        allow(redis).to receive(:set)
          .with('key', MultiJson.dump(resource))
          .and_return('OK')
      end
      it { expect(repository.update(resource)).to eq 'OK' }
    end

    describe 'delete' do
      before do
        allow(redis).to receive(:del)
          .with('key')
          .and_return('OK')
      end
      it { expect(repository.delete('key')).to eq 'OK' }
    end

    describe 'find' do
      let(:resource) do
        { name: 'key', attr: '1' }
      end
      before do
        allow(redis).to receive(:get)
          .with('key')
          .and_return(MultiJson.dump(resource))
      end
      it { expect(repository.find('key')).to eq resource }
    end
  end
end

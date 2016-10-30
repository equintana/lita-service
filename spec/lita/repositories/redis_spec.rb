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
  end
end

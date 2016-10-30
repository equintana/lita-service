require 'spec_helper'

describe Lita::Handlers::Service, lita_handler: true do
  describe 'routes' do
    it { is_expected.to route('ping').to(:pong) }
    it { is_expected.to route('create awesome-service').to(:create) }
    it { is_expected.to route('create awesome-service 2000').to(:create) }
  end

  describe 'callbacks' do
    describe 'ping' do
      it 'replies pong' do
        send_message('ping')
        expect(replies.last).to eq 'pong!'
      end
    end

    describe 'create' do
      describe 'name not taken' do
        let(:success_message) do
          "Yay! awesome-service service was created.\n" \
            "Add customers with:\n" \
            'lita service awesome-service inscribe to < USER > < *VALUE >'
        end

        it 'creates a service with name' do
          send_message('create awesome-service')
          expect(replies.last).to eq(success_message)
        end

        it 'creates a service with name and value' do
          send_message('create awesome-service 2000')
          expect(replies.last).to eq(success_message)
        end
      end

      describe 'name taken' do
        let(:error_message) do
          'ERROR: A service called awesome-service exist already'
        end

        it 'replys with an error' do
          send_message('create awesome-service')
          send_message('create awesome-service')
          expect(replies.last).to eq(error_message)
        end
      end
    end
  end
end

# frozen_string_literal: false
require 'spec_helper'

describe Lita::Handlers::Service, lita_handler: true do
  describe 'routes' do
    it { is_expected.to route('ping').to(:pong) }
    it { is_expected.to route('create TheService').to(:create) }
    it { is_expected.to route('create TheService 2000').to(:create) }
    it { is_expected.to route('show TheService').to(:show) }
    it { is_expected.to route('delete TheService').to(:delete) }
    it { is_expected.to route('TheService inscribe erlinis').to(:inscribe) }
    it { is_expected.to route('TheService inscribe @erlinis').to(:inscribe) }
    it { is_expected.to route('TheService inscribe @erlinis 20').to(:inscribe) }
    it { is_expected.to route('TheService add @erlinis 2').to(:add) }
    it { is_expected.to route('TheService add @erlinis -2').to(:add) }
    it { is_expected.to route('TheService add @erlinis').to(:add) }
    it { is_expected.to route('TheService delete @erlinis').to(:delete_customer) }
    it { is_expected.to route('TheService remove erlinis').to(:delete_customer) }
  end

  describe 'callbacks' do
    describe '#ping' do
      it 'replies pong' do
        send_message('ping')
        expect(replies.last).to eq 'pong!'
      end
    end

    describe '#create' do
      describe 'name not taken' do
        let(:success_message) do
          "Yay! TheService service was created.\n" \
            "Add customers with:\n" \
            'lita service TheService inscribe < CUSTOMER > < *VALUE >'
        end

        it 'creates a service with name' do
          send_message('create TheService')
          expect(replies.last).to eq(success_message)
        end

        it 'creates a service with name and value' do
          send_message('create TheService 2000')
          expect(replies.last).to eq(success_message)
        end
      end

      describe 'name taken' do
        let(:error_message) do
          'ERROR: A service called TheService exist already.'
        end

        it 'replys with an error' do
          send_message('create TheService')
          send_message('create TheService')
          expect(replies.last).to eq(error_message)
        end
      end
    end

    describe '#show' do
      describe 'when the service exists' do
        before do
          send_message('create TheService 2000')
        end

        describe 'without customers' do
          let(:empty_message) do
            "\nTheService\n" \
      	      "  No customers yet :(\n\n" \
      	      "  Add customers with:\n" \
      	      "lita service TheService inscribe < CUSTOMER > < *VALUE >\n"
          end

          it 'shows an empty state message' do
            send_message('show TheService')
            expect(replies.last).to eq(empty_message)
          end
        end

        describe 'with customers' do
          let(:service_data) do
            "\nTheService\n" \
             "-------------------------------------------------------------\n" \
             "  #  | Name                 | Quantity | Value    | Total    \n" \
             "-----+----------------------+----------+----------+----------\n" \
             "   1 | erlinis              | 1        | 2000     | 2000     \n" \
             "   2 | khal                 | 2        | 2000     | 4000     \n" \
             "-----+----------------------+----------+----------+----------\n" \
             "     | Total                | 3        | ***      | 6000     \n" \
             "-------------------------------------------------------------\n"
          end

          before do
            send_message('create TheService 2000')
            send_message('TheService inscribe erlinis 2000')
            send_message('TheService inscribe khal 2000')
            send_message('TheService add erlinis 1')
            send_message('TheService add khal 2')
          end

          it 'shows the service' do
            send_message('show TheService')
            expect(replies.last).to eq(service_data)
          end
        end
      end

      describe 'when service does not exist' do
        let(:error_message) do
          "ERROR: There isn't a service called TheService " \
            'or it was deleted.'
        end

        it 'replys with an error' do
          send_message('show TheService')
          expect(replies.last).to eq(error_message)
        end
      end
    end
    describe '#delete' do
      describe 'when the service exists' do
        let(:success_message) { 'Service TheService was deleted.' }
        before do
          send_message('create TheService')
        end

        it 'deletes the service' do
          send_message('delete TheService')
          expect(replies.last).to eq(success_message)
        end
      end

      describe 'when service does not exist' do
        let(:error_message) do
          "ERROR: There isn't a service called TheService " \
            'or it was deleted.'
        end

        it 'replys with an error' do
          send_message('delete TheService')
          expect(replies.last).to eq(error_message)
        end
      end
    end

    describe '#inscribe' do
      describe 'when service exists' do
        before do
          send_message('create TheService')
          send_message('TheService inscribe @erlinis 2000')
        end

        describe 'customer not inscribed' do
          let(:success_message) { 'erlinis was inscribed to TheService.' }

          it 'inscribes the customer' do
            expect(replies.last).to eq(success_message)
          end
        end

        describe 'customer inscribed already' do
          let(:error_message) { 'ERROR: erlinis is already in TheService.' }

          it 'returns an error' do
            send_message('TheService inscribe @erlinis 2000')
            expect(replies.last).to eq(error_message)
          end
        end
      end

      describe 'when service does not exit' do
        let(:error_message) do
          "ERROR: There isn't a service called TheService " \
            'or it was deleted.'
        end

        it 'replys with an error' do
          send_message('TheService inscribe @erlinis')
          expect(replies.last).to eq(error_message)
        end
      end
    end

    describe '#delete_customer' do
      describe 'when service exists' do
        before do
          send_message('create TheService')
        end

        describe 'customer in service' do
          let(:success_message) { 'erlinis was deleted from TheService.' }
          before do
            send_message('TheService inscribe @erlinis 2000')
          end

          it 'removes the customer' do
            send_message('TheService delete @erlinis')
            expect(replies.last).to eq(success_message)
          end
        end

        describe 'customer not in service' do
          let(:error_message) { 'ERROR: There is no erlinis in TheService.' }

          it 'returns an error' do
            send_message('TheService delete @erlinis')
            expect(replies.last).to eq(error_message)
          end
        end
      end

      describe 'when service does not exit' do
        let(:error_message) do
          "ERROR: There isn't a service called TheService " \
            'or it was deleted.'
        end

        it 'replys with an error' do
          send_message('TheService delete @erlinis')
          expect(replies.last).to eq(error_message)
        end
      end
    end

    describe '#add' do
      describe 'when service exists' do
        before do
          send_message('create TheService')
          send_message('TheService inscribe @erlinis 2000')
        end

        describe 'with positive quantity' do
          let(:success_message) { '2 was added to erlinis, new quantity: 2' }
          it 'inscrease the customer quantity' do
            send_message('TheService add @erlinis 2')
            expect(replies.last).to eq(success_message)
          end
        end

        describe 'with negative quantity' do
          let(:success_message) { '-1 was added to erlinis, new quantity: 4' }
          it 'decrease the customer quantity' do
            send_message('TheService add @erlinis 5')
            send_message('TheService add @erlinis -1')
            expect(replies.last).to eq(success_message)
          end
        end
      end

      describe ' when service does not exit' do
        let(:error_message) do
          "ERROR: There isn't a service called TheService " \
            'or it was deleted.'
        end

        it 'replys with an error' do
          send_message('TheService inscribe @erlinis')
          expect(replies.last).to eq(error_message)
        end
      end
    end
  end
end

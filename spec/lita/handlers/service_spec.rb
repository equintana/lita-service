# frozen_string_literal: false
require 'spec_helper'

describe Lita::Handlers::Service, lita_handler: true do
  describe 'routes' do
    it { is_expected.to route_command('ping').to(:pong) }
    it { is_expected.to route_command('list').to(:list) }
    it { is_expected.to route_command('create TheService').to(:create) }
    it { is_expected.to route_command('create TheService 2000').to(:create) }
    it { is_expected.to route_command('show TheService').to(:show) }
    it { is_expected.to route_command('service delete TheService').to(:delete) }
    it { is_expected.to route_command('service remove TheService').to(:delete) }
    it { is_expected.to route_command('TheService add all').to(:add_all) }
    it { is_expected.to route_command('TheService add all 2').to(:add_all) }
    it { is_expected.to route_command('TheService sum all 2').to(:add_all) }
    it { is_expected.to route_command('TheService inscribe @erlinis').to(:inscribe) }
    it { is_expected.to route_command('TheService inscribe @erlinis 20').to(:inscribe) }
    it { is_expected.to route_command('TheService add @erlinis 2').to(:add) }
    it { is_expected.to route_command('TheService add @erlinis -2').to(:add) }
    it { is_expected.to route_command('TheService add @erlinis').to(:add) }
    it { is_expected.to route_command('TheService sum @erlinis 2').to(:add) }
    it { is_expected.to route_command('TheService sum @erlinis').to(:add) }
    it { is_expected.to route_command('TheService delete erlinis').to(:delete_customer) }
    it { is_expected.to route_command('TheService remove erlinis').to(:delete_customer) }
  end

  describe 'callbacks' do
    describe '#ping' do
      it 'replies pong' do
        send_command('ping')
        expect(replies.last).to eq 'pong!'
      end
    end

    describe '#list' do
      describe 'with services' do
        let(:list_of_services) do
          "1. ServiceOne\n"\
          "2. ServiceTwo\n"
        end

        before do
          send_command('create ServiceOne')
          send_command('create ServiceTwo')
        end

        it 'list all services' do
          send_command('service list')
          expect(replies.last).to eq(list_of_services)
        end
      end

      describe 'without services' do
        let(:empty_message) { 'Nothing to see here.' }

        it 'show an empty state message' do
          send_command('service list')
          expect(replies.last).to eq(empty_message)
        end
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
          send_command('create TheService')
          expect(replies.last).to eq(success_message)
        end

        it 'creates a service with name and value' do
          send_command('create TheService 2000')
          expect(replies.last).to eq(success_message)
        end
      end

      describe 'name taken' do
        let(:error_message) do
          'ERROR: A service called TheService exist already.'
        end

        it 'replys with an error' do
          send_command('create TheService')
          send_command('create TheService')
          expect(replies.last).to eq(error_message)
        end
      end
    end

    describe '#show' do
      describe 'when the service exists' do
        before do
          send_command('create TheService')
        end

        describe 'without customers' do
          let(:empty_message) do
            "\nTheService\n" \
              "  No customers yet :(\n\n" \
              "  Add customers with:\n" \
              "lita service TheService inscribe < CUSTOMER > < *VALUE >\n"
          end

          it 'shows an empty state message' do
            send_command('show TheService')
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
            send_command('create TheService 2000')
            send_command('TheService inscribe erlinis 2000')
            send_command('TheService inscribe khal 2000')
            send_command('TheService add erlinis 1')
            send_command('TheService add khal 2')
          end

          it 'shows the service' do
            send_command('show TheService')
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
          send_command('show TheService')
          expect(replies.last).to eq(error_message)
        end
      end
    end

    describe '#delete' do
      describe 'when the service exists' do
        let(:success_message) { 'Service TheService was deleted.' }
        before do
          send_command('create TheService')
        end

        it 'deletes the service' do
          send_command('service delete TheService')
          expect(replies.last).to eq(success_message)
        end
      end

      describe 'when service does not exist' do
        let(:error_message) do
          "ERROR: There isn't a service called TheService " \
            'or it was deleted.'
        end

        it 'replys with an error' do
          send_command('service delete TheService')
          expect(replies.last).to eq(error_message)
        end
      end
    end

    describe '#inscribe' do
      describe 'when service exists' do
        before do
          send_command('create TheService')
          send_command('TheService inscribe @erlinis 2000')
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
            send_command('TheService inscribe @erlinis 2000')
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
          send_command('TheService inscribe @erlinis')
          expect(replies.last).to eq(error_message)
        end
      end
    end

    describe '#delete_customer' do
      describe 'when service exists' do
        before do
          send_command('create TheService')
        end

        describe 'customer in service' do
          let(:success_message) { 'erlinis was deleted from TheService.' }
          before do
            send_command('TheService inscribe @erlinis 2000')
          end

          it 'removes the customer' do
            send_command('TheService delete @erlinis')
            expect(replies.last).to eq(success_message)
          end
        end

        describe 'customer not in service' do
          let(:error_message) { 'ERROR: There is no erlinis in TheService.' }

          it 'returns an error' do
            send_command('TheService delete @erlinis')
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
          send_command('TheService delete @erlinis')
          expect(replies.last).to eq(error_message)
        end
      end
    end

    describe '#add' do
      describe 'when service exists' do
        before do
          send_command('create TheService')
          send_command('TheService inscribe @erlinis 2000')
        end

        describe 'with positive quantity' do
          let(:success_message) { '2 was added to erlinis, new quantity: 2' }
          it 'inscrease the customer quantity' do
            send_command('TheService add @erlinis 2')
            expect(replies.last).to eq(success_message)
          end
        end

        describe 'with negative quantity' do
          let(:success_message) { '-1 was added to erlinis, new quantity: 4' }
          it 'decrease the customer quantity' do
            send_command('TheService add @erlinis 5')
            send_command('TheService add @erlinis -1')
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
          send_command('TheService inscribe @erlinis')
          expect(replies.last).to eq(error_message)
        end
      end
    end

    describe '#add_all' do
      describe 'when service exists' do
        let(:success_message) { "#{quantity} was added to all." }

        before do
          send_command('create TheService')
          send_command('TheService inscribe @erlinis 2000')
          send_command('TheService inscribe @khal 2000')
          send_command('TheService add @erlinis 1')
        end

        describe 'with positive quantity' do
          let(:quantity) { 2 }

          it 'inscrease all customer quantity' do
            send_command('TheService add all 2')
            expect(replies.last).to eq(success_message)
          end
        end

        describe 'with negative quantity' do
          let(:quantity) { -1 }

          it 'decrease the customer quantity' do
            send_command('TheService add all -1')
            expect(replies.last).to eq(success_message)
          end
        end

        describe 'without a quantity' do
          let(:quantity) { 1 }

          it 'inscrease all customers quantity with default quantity' do
            send_command('TheService sum all 1')
            expect(replies.last).to eq(success_message)
          end
        end
      end

      describe 'when service does not exit' do
        let(:error_message) do
          "ERROR: There isn't a service called TheService " \
            'or it was deleted.'
        end

        it 'replys with an error' do
          send_command('TheService sum all')
          expect(replies.last).to eq(error_message)
        end
      end
    end
  end
end

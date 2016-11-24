# frozen_string_literal: false
require 'spec_helper'

describe Lita::Handlers::Service, lita_handler: true do
  describe 'routes' do
    it { is_expected.to route_command('service ping').to(:pong) }
    it { is_expected.to route_command('service list').to(:list) }
    it { is_expected.to route_command('service create XYZ').to(:create) }
    it { is_expected.to route_command('service create XYZ 2000').to(:create) }
    it { is_expected.to route_command('service show XYZ').to(:show) }
    it { is_expected.to route_command('service service delete XYZ').to(:delete) }
    it { is_expected.to route_command('service service remove XYZ').to(:delete) }
    it { is_expected.to route_command('service XYZ add all').to(:add_all) }
    it { is_expected.to route_command('service XYZ add all 2').to(:add_all) }
    it { is_expected.to route_command('service XYZ sum all 2').to(:add_all) }
    it { is_expected.to route_command('service XYZ inscribe @jhon').to(:inscribe) }
    it { is_expected.to route_command('service XYZ inscribe @jhon 20').to(:inscribe) }
    it { is_expected.to route_command('service XYZ add @jhon 2').to(:add) }
    it { is_expected.to route_command('service XYZ add @jhon -2').to(:add) }
    it { is_expected.to route_command('service XYZ add @jhon').to(:add) }
    it { is_expected.to route_command('service XYZ sum @jhon 2').to(:add) }
    it { is_expected.to route_command('service XYZ sum @jhon').to(:add) }
    it { is_expected.to route_command('service XYZ delete jhon').to(:delete_customer) }
    it { is_expected.to route_command('service XYZ remove jhon').to(:delete_customer) }
  end

  describe 'callbacks' do
    let(:service_not_found_error) do
      "ERROR: There isn't a service called TheService or it was deleted."
    end

    describe '#ping' do
      it 'replies pong' do
        send_command('service ping')
        expect(replies.last).to eq 'pong!'
      end
    end

    describe '#list' do
      describe 'with services' do
        before do
          send_command('service create ABC')
          send_command('service create XYZ')
        end

        it 'list all services' do
          send_command('service list')
          expect(replies.last).to include('XYZ', 'ABC')
        end
      end

      describe 'without services' do
        it 'show an empty state message' do
          empty_message = 'Nothing to see here.'
          send_command('service list')
          expect(replies.last).to eq(empty_message)
        end
      end
    end

    describe '#create' do
      describe 'name not taken' do
        let(:success_message) do
          "Yay! TheService service was created.\n"\
          "Add customers with:\n"\
          'lita service TheService inscribe < CUSTOMER > < *VALUE >'
        end

        it 'creates a service with name' do
          send_command('service create TheService')
          expect(replies.last).to eq(success_message)
        end

        it 'creates a service with name and value' do
          send_command('service create TheService 2000')
          expect(replies.last).to eq(success_message)
        end
      end

      describe 'name taken' do
        it 'replys with an error' do
          error_message = 'ERROR: A service called TheService exist already.'
          send_command('service create TheService')
          send_command('service create TheService')
          expect(replies.last).to eq(error_message)
        end
      end
    end

    describe '#show' do
      describe 'when the service exists' do
        before do
          send_command('service create TheService')
        end

        describe 'without customers' do
          it 'shows an empty state message' do
            empty_message = "\nTheService\n" \
              "  No customers yet :(\n\n" \
              "  Add customers with:\n" \
              "lita service TheService inscribe < CUSTOMER > < *VALUE >\n"

            send_command('service show TheService')
            expect(replies.last).to eq(empty_message)
          end
        end

        describe 'with customers' do
          before do
            send_command('service create TheService 2000')
            send_command('service TheService inscribe erlinis 2000')
            send_command('service TheService inscribe khal 2000')
            send_command('service TheService add erlinis 1')
            send_command('service TheService add khal 2')
          end

          it 'shows the service' do
            service_data = "\nTheService\n" \
              "```\n" \
              "-------------------------------------------------------------\n" \
              "  #  | Name                 | Quantity | Value    | Total    \n" \
              "-----+----------------------+----------+----------+----------\n" \
              "   1 | erlinis              | 1        | 2000     | 2000     \n" \
              "   2 | khal                 | 2        | 2000     | 4000     \n" \
              "-----+----------------------+----------+----------+----------\n" \
              "     | Total                | 3        | ***      | 6000     \n" \
              "-------------------------------------------------------------\n" \
              '```'

            send_command('service show TheService')
            expect(replies.last).to eq(service_data)
          end
        end
      end

      describe 'when service does not exist' do
        it 'replys with an error' do
          send_command('service show TheService')
          expect(replies.last).to eq(service_not_found_error)
        end
      end
    end

    describe '#delete' do
      describe 'when the service exists' do
        before do
          send_command('service create TheService')
        end

        it 'deletes the service' do
          success_message = 'Service TheService was deleted.'
          send_command('service delete TheService')
          expect(replies.last).to eq(success_message)
        end
      end

      describe 'when service does not exist' do
        it 'replys with an error' do
          send_command('service delete TheService')
          expect(replies.last).to eq(service_not_found_error)
        end
      end
    end

    describe '#inscribe' do
      describe 'when service exists' do
        before do
          send_command('service create TheService')
          send_command('service TheService inscribe @erlinis 2000')
        end

        it 'inscribes the customer if not in service' do
          success_message = 'erlinis was inscribed to TheService.'
          expect(replies.last).to eq(success_message)
        end

        it 'returns an error is customer inscribed already' do
          error = 'ERROR: erlinis is already in TheService.'
          send_command('service TheService inscribe @erlinis 2000')
          expect(replies.last).to eq(error)
        end
      end

      describe 'when service does not exit' do
        it 'replys with an error' do
          send_command('service TheService inscribe @erlinis')
          expect(replies.last).to eq(service_not_found_error)
        end
      end
    end

    describe '#delete_customer' do
      describe 'when service exists' do
        before do
          send_command('service create TheService')
        end

        describe 'customer in service' do
          before do
            send_command('service TheService inscribe @erlinis 2000')
          end

          it 'removes the customer' do
            success_message = 'erlinis was deleted from TheService.'
            send_command('service TheService delete @erlinis')
            expect(replies.last).to eq(success_message)
          end
        end

        describe 'customer not in service' do
          it 'returns an error' do
            error = 'ERROR: There is no erlinis in TheService.'
            send_command('service TheService delete @erlinis')
            expect(replies.last).to eq(error)
          end
        end
      end

      describe 'when service does not exit' do
        it 'replys with an error' do
          send_command('service TheService delete @erlinis')
          expect(replies.last).to eq(service_not_found_error)
        end
      end
    end

    describe '#add' do
      describe 'when service exists' do
        before do
          send_command('service create TheService')
          send_command('service TheService inscribe @erlinis 2000')
        end

        describe 'with positive quantity' do
          it 'inscrease the customer quantity' do
            success_message = '2 was added to erlinis, new quantity: 2'
            send_command('service TheService add @erlinis 2')
            expect(replies.last).to eq(success_message)
          end
        end

        describe 'with negative quantity' do
          it 'decrease the customer quantity' do
            success_message = '-1 was added to erlinis, new quantity: 4'
            send_command('service TheService add @erlinis 5')
            send_command('service TheService add @erlinis -1')
            expect(replies.last).to eq(success_message)
          end
        end
      end

      describe ' when service does not exit' do
        it 'replys with an error' do
          send_command('service TheService inscribe @erlinis')
          expect(replies.last).to eq(service_not_found_error)
        end
      end
    end

    describe '#add_all' do
      describe 'when service exists' do
        let(:success_message) { "#{quantity} was added to all." }

        before do
          send_command('service create TheService')
          send_command('service TheService inscribe @erlinis 2000')
          send_command('service TheService inscribe @khal 2000')
          send_command('service TheService add @erlinis 1')
        end

        describe 'with positive quantity' do
          let(:quantity) { 2 }

          it 'inscrease all customer quantity' do
            send_command('service TheService add all 2')
            expect(replies.last).to eq(success_message)
          end
        end

        describe 'with negative quantity' do
          let(:quantity) { -1 }

          it 'decrease the customer quantity' do
            send_command('service TheService add all -1')
            expect(replies.last).to eq(success_message)
          end
        end

        describe 'without a quantity' do
          let(:quantity) { 1 }

          it 'inscrease all customers quantity with default quantity' do
            send_command('service TheService sum all 1')
            expect(replies.last).to eq(success_message)
          end
        end
      end

      describe 'when service does not exit' do
        it 'replys with an error' do
          send_command('service TheService sum all')
          expect(replies.last).to eq(service_not_found_error)
        end
      end
    end
  end
end

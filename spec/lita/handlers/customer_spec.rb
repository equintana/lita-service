# frozen_string_literal: false
require 'spec_helper'
# require 'lita/handlers/service'

describe Lita::Handlers::Customer, lita_handler: true,
                                   additional_lita_handlers: Lita::Handlers::Service do
  describe 'routes' do
    it { is_expected.to route_command('service XYZ inscribe @jhon').to(:inscribe) }
    it { is_expected.to route_command('service XYZ inscribe @jhon 20').to(:inscribe) }
    it { is_expected.to route_command('service XYZ value @jhon 2000').to(:change_value) }
    it { is_expected.to route_command('service XYZ add @jhon 2').to(:add) }
    it { is_expected.to route_command('service XYZ add @jhon -2').to(:add) }
    it { is_expected.to route_command('service XYZ add @jhon').to(:add) }
    it { is_expected.to route_command('service XYZ sum @jhon 2').to(:add) }
    it { is_expected.to route_command('service XYZ sum @jhon').to(:add) }
    it { is_expected.to route_command('service XYZ add all').to(:add_all) }
    it { is_expected.to route_command('service XYZ add all 2').to(:add_all) }
    it { is_expected.to route_command('service XYZ sum all 2').to(:add_all) }
    it { is_expected.to route_command('service XYZ delete jhon').to(:delete_customer) }
    it { is_expected.to route_command('service XYZ remove jhon').to(:delete_customer) }
  end

  describe 'callbacks' do
    let(:service_not_found_error) do
      "_ERROR: There isn't a service called *TheService* or it was deleted._"
    end

    describe '#inscribe' do
      describe 'when service exists' do
        before do
          send_command('service create TheService')
          send_command('service TheService inscribe @erlinis 2000')
        end

        it 'inscribes the customer if not in service' do
          success_message = '_*erlinis* was inscribed to *TheService*._'
          expect(replies.last).to eq(success_message)
        end

        it 'returns an error is customer inscribed already' do
          error = '_ERROR: *erlinis* is already in *TheService*._'
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

    describe '#value' do
      describe 'when service exists' do
        before do
          send_command('service create TheService')
          send_command('service TheService inscribe @erlinis 2000')
        end

        it 'changes the customer values if not in service' do
          success_message = '_*erlinis* value was changed from *2000* to *1000*._'
          send_command('service TheService value @erlinis 1000')
          expect(replies.last).to eq(success_message)
        end
      end

      describe 'when service does not exit' do
        it 'replys with an error' do
          send_command('service TheService value @erlinis 1000')
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
            success_message = '_*erlinis* was deleted from *TheService*._'
            send_command('service TheService delete @erlinis')
            expect(replies.last).to eq(success_message)
          end
        end

        describe 'customer not in service' do
          it 'returns an error' do
            error = '_ERROR: There is no *erlinis* in *TheService*._'
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
            success_message = '_*2* was added to *erlinis*, new quantity: *2*_'
            send_command('service TheService add @erlinis 2')
            expect(replies.last).to eq(success_message)
          end
        end

        describe 'with negative quantity' do
          it 'decrease the customer quantity' do
            success_message = '_*-1* was added to *erlinis*, new quantity: *4*_'
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
        let(:success_message) { "_*#{quantity}* was added to all._" }

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

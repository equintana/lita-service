# frozen_string_literal: false
require 'spec_helper'
# require 'lita/handlers/customer'

describe Lita::Handlers::Service, lita_handler: true,
                                  additional_lita_handlers: Lita::Handlers::Customer do
  describe 'routes' do
    it { is_expected.to route_command('service ping').to(:pong) }
    it { is_expected.to route_command('service list').to(:list) }
    it { is_expected.to route_command('service create XYZ').to(:create) }
    it { is_expected.to route_command('service create XYZ 2000').to(:create) }
    it { is_expected.to route_command('service show XYZ').to(:show) }
    it { is_expected.to route_command('service service delete XYZ').to(:delete) }
    it { is_expected.to route_command('service service remove XYZ').to(:delete) }
  end

  describe 'callbacks' do
    let(:service_not_found_error) do
      "_ERROR: There isn't a service called *TheService* or it was deleted._"
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
        it 'shows an empty state message' do
          empty_message = "Services List\n_Nothing to see here._\n"
          send_command('service list')
          expect(replies.last).to eq(empty_message)
        end
      end
    end

    describe '#create' do
      describe 'name not taken' do
        let(:success_message) do
          '_Yay! *TheService* service was created._'
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
          error_message = '_ERROR: A service called *TheService* exist already._'
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
            empty_message = "\n*TheService*\n\n_No customers yet :(_\n"

            send_command('service show TheService')
            expect(replies.last).to eq(empty_message)
          end
        end

        describe 'with customers' do
          let(:fake_time) { Time.parse('2017-04-05T17:57:57.918Z') }
          before do
            allow(Time).to receive(:now).and_return(fake_time)
            send_command('service create TheService 2000')
            send_command('service TheService inscribe erlinis 2000')
            send_command('service TheService inscribe khal 2000')
            send_command('service TheService add erlinis 1')
            send_command('service TheService add khal 2')
          end

          # rubocop:disable LineLength
          it 'shows the service' do
            service_data = "\n*TheService*\n\n" \
              "```\n" \
              "+---+---------+----------+-------+-------+-------------------+------------+\n" \
              "| # | Name    | Quantity | Value | Total | Updated At        | Updated By |\n" \
              "+---+---------+----------+-------+-------+-------------------+------------+\n" \
              "| 1 | erlinis | 1        | 2000  | 2000  | 05/Apr/2017 17:57 | Test User  |\n" \
              "| 2 | khal    | 2        | 2000  | 4000  | 05/Apr/2017 17:57 | Test User  |\n" \
              "+---+---------+----------+-------+-------+-------------------+------------+\n" \
              "|   | Total   | 3        | ***   | 6000  |                   |            |\n" \
              "+---+---------+----------+-------+-------+-------------------+------------+\n" \
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
          success_message = '_Service *TheService* was deleted._'
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
  end
end

# frozen_string_literal: true
require 'lita/helpers/messages_helper'

module Lita
  module Interactors
    # Inscribes a customer in a service
    class DeleteCustomer < BaseInteractor
      include Lita::Helpers::MessagesHelper

      attr_reader :data

      def initialize(handler, data)
        @handler = handler
        @data = data
      end

      def perform
        if service_exists?
          delete_customer_if_in_service
        else
          @error = msg_not_found(service_name: name)
        end
        self
      end

      private

      def name
        @name ||= data[1]
      end

      def customer_name
        @customer_name ||= data[3].delete('@')
      end

      def service
        @service ||= repository.find(name)
      end

      def service_exists?
        repository.exists?(name)
      end

      def customer_in_service?
        service[:customers].keys.include?(customer_name.to_sym)
      end

      def delete_customer_if_in_service
        if customer_in_service?
          delete_customer_from_service
        else
          @error = msg_customer_not_found(service_name: name,
                                          customer_name: customer_name)
        end
      end

      def delete_customer_from_service
        service[:customers].delete(customer_name.to_sym)
        repository.update(service)
        @message = I18n.t('lita.handlers.service.delete_customer.success',
                          service_name: name, customer_name: customer_name)
      end
    end
  end
end

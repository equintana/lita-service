# frozen_string_literal: true
require 'lita/helpers/messages_helper'

module Lita
  module Interactors
    # Set the customer quantity to zero
    class ResetQuantity < BaseInteractor
      include Lita::Helpers::MessagesHelper

      attr_reader :data

      def initialize(handler, data)
        @handler = handler
        @data = data
      end

      def perform
        if service_exists?
          update_costumer_if_exist
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
        @customer_name ||= data[2].delete('@')
      end

      def service
        @service ||= repository.find(name)
      end

      def customer
        service[:customers][customer_name.to_sym]
      end

      def service_exists?
        repository.exists?(name)
      end

      def customer_exists?
        service[:customers].keys.include?(customer_name.to_sym)
      end

      def update_costumer_if_exist
        if customer_exists?
          update_customer_quantity
        else
          @error = msg_customer_not_found(service_name: name,
                                          customer_name: customer_name)
        end
      end

      def update_customer_quantity
        reset_quantity
        repository.update(service)
      end

      def reset_quantity
        customer[:quantity] = 0

        @message = I18n.t('lita.handlers.service.reset.success',
                          customer_name: customer_name)
      end
    end
  end
end

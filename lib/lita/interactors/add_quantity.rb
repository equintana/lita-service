# frozen_string_literal: true
require 'lita/helpers/messages_helper'

module Lita
  module Interactors
    # Inscribes a customer in a service
    class AddQuantity < BaseInteractor
      include Lita::Helpers::MessagesHelper

      attr_reader :data
      DEFAULT_QUANTITY = 1

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
        @customer_name ||= data[3].delete('@')
      end

      def customer_quantity
        @customer_quantity ||= data[4].to_s
      end

      def service
        @service ||= repository.find(name)
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
        new_quantity = increment_quantity
        repository.update(service)
        @message = I18n.t('lita.handlers.service.add.success',
                          quantity: quantity_calculated,
                          customer_name: customer_name,
                          customer_quantity: new_quantity)
      end

      def increment_quantity
        service[:customers][customer_name.to_sym][:quantity] += quantity_calculated
      end

      def quantity_calculated
        return customer_quantity.to_i unless customer_quantity.empty?
        DEFAULT_QUANTITY
      end
    end
  end
end

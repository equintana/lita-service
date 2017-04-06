# frozen_string_literal: true
require 'lita/helpers/messages_helper'
require 'lita/helpers/last_update_helper'

module Lita
  module Interactors
    # Adds the given quantity to the customer's balance
    class AddQuantity < BaseInteractor
      include Lita::Helpers::MessagesHelper
      include Lita::Helpers::LastUpdateHelper

      attr_reader :service_name, :customer_quantity, :customer_name, :user
      DEFAULT_QUANTITY = 1

      def initialize(handler, data, user)
        @handler           = handler
        @service_name      = data[1]
        @customer_quantity = data[4].to_s
        @customer_name     = data[3].delete('@')
        @user              = user
      end

      def perform
        if service_exists?
          update_costumer_if_exist
        else
          @error = msg_not_found(service_name: service_name)
        end
        self
      end

      private

      def service
        @service ||= repository.find(service_name)
      end

      def service_exists?
        repository.exists?(service_name)
      end

      def customer_exists?
        service[:customers].keys.include?(customer_name.to_sym)
      end

      def update_costumer_if_exist
        if customer_exists?
          update_customer_quantity
          update_last_changed_data(service, customer_name, user)
          repository.update(service)
        else
          @error = msg_customer_not_found(service_name: service_name,
                                          customer_name: customer_name)
        end
      end

      def update_customer_quantity
        new_quantity = increment_quantity
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

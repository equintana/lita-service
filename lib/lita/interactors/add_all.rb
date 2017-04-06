# frozen_string_literal: true
require 'lita/helpers/messages_helper'

module Lita
  module Interactors
    # Increases all customers' quantity with the given value
    # or with 1 if nothing is specified.
    class AddAll < BaseInteractor
      include Lita::Helpers::MessagesHelper
      include Lita::Helpers::LastUpdateHelper

      attr_reader :service_name, :given_quantity, :user
      DEFAULT_QUANTITY = 1

      def initialize(handler, data, user)
        @handler        = handler
        @service_name   = data[1]
        @given_quantity = data[3].to_s
        @user = user
      end

      def perform
        if service_exists?
          update_all_quantities
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

      def update_all_quantities
        increment_quantities
        repository.update(service)
        @message = I18n.t('lita.handlers.service.add_all.success',
                          quantity: quantity_calculated)
      end

      def increment_quantities
        quantity = quantity_calculated
        service[:customers].map do |customer_name, customer|
          increment_customer_quantity(customer, quantity)
          update_last_changed_data(service, customer_name, user)
        end
      end

      def increment_customer_quantity(customer, quantity)
        customer[:quantity] += quantity
      end

      def quantity_calculated
        return given_quantity.to_i unless given_quantity.empty?
        DEFAULT_QUANTITY
      end
    end
  end
end

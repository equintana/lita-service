# frozen_string_literal: true
require 'lita/helpers/messages_helper'

module Lita
  module Interactors
    # Increases all customers' quantity with the given value
    # or with 1 if nothing is specified.
    class AddAll < BaseInteractor
      include Lita::Helpers::MessagesHelper

      attr_reader :data
      DEFAULT_QUANTITY = 1

      def initialize(handler, data)
        @handler = handler
        @data = data
      end

      def perform
        if service_exists?
          update_all_quantities
        else
          @error = msg_not_found(service_name: name)
        end
        self
      end

      private

      def name
        @name ||= data[1]
      end

      def given_quantity
        @customer_quantity ||= data[3].to_s
      end

      def service
        @service ||= repository.find(name)
      end

      def service_exists?
        repository.exists?(name)
      end

      def update_all_quantities
        increment_quantities
        repository.update(service)
        @message = I18n.t('lita.handlers.service.add_all.success',
                          quantity: quantity_calculated)
      end

      def increment_quantities
        quantity = quantity_calculated
        service[:customers].map do |_key, customer_data|
          customer_data[:quantity] += quantity
        end
      end

      def quantity_calculated
        return given_quantity.to_i unless given_quantity.empty?
        DEFAULT_QUANTITY
      end
    end
  end
end

# frozen_string_literal: true
require 'lita/helpers/messages_helper'

module Lita
  module Interactors
    # Set the given value to a user
    class ChangeValue < BaseInteractor
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

      def customer_value
        @customer_value ||= data[3].to_i
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
          update_customer_value
        else
          @error = msg_customer_not_found(service_name: name,
                                          customer_name: customer_name)
        end
      end

      def update_customer_value
        change_value
        repository.update(service)
      end

      def change_value
        old_value = customer[:value]
        customer[:value] = customer_value

        @message = I18n.t('lita.handlers.service.set_value.success',
                          old_value: old_value,
                          customer_name: customer_name,
                          customer_value: customer_value)
      end
    end
  end
end

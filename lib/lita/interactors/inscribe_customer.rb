# frozen_string_literal: true
require 'lita/helpers/messages_helper'

module Lita
  module Interactors
    # Inscribes a customer in a service
    class InscribeCustomer < BaseInteractor
      include Lita::Helpers::MessagesHelper

      attr_reader :data

      def initialize(handler, data)
        @handler = handler
        @data = data
      end

      def perform
        if service_exists?
          if new_customer?
            add_customer
          else
            @error = msg_customer_duplicated(service_name: name, customer: customer_name)
          end
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
        @customer_value ||= data[3].to_s
      end

      def service
        @service ||= repository.find(name)
      end

      def service_exists?
        repository.exists?(name)
      end

      def new_customer?
        !service[:customers].keys.include?(customer_name.to_sym)
      end

      def add_customer
        service[:customers][customer_name.to_sym] = customer
        repository.update(service)
        @message = I18n.t('lita.handlers.service.inscribe.success',
                          service_name: name, customer_name: customer_name)
      end

      def customer
        {
          quantity: 0,
          value: calculate_value
        }
      end

      def calculate_value
        return customer_value.to_i unless customer_value.empty?
        service[:value]
      end
    end
  end
end

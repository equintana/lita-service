# frozen_string_literal: true
require 'lita/helpers/messages_helper'
require 'lita/helpers/last_update_helper'

module Lita
  module Interactors
    # Set the customer quantity to zero
    class ResetQuantity < BaseInteractor
      include Lita::Helpers::MessagesHelper
      include Lita::Helpers::LastUpdateHelper

      attr_reader :service_name, :customer_name, :user

      def initialize(handler, data, user)
        @handler           = handler
        @service_name      = data[1]
        @customer_name     = data[2].delete('@')
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

      def customer
        service[:customers][customer_name.to_sym]
      end

      def service_exists?
        repository.exists?(service_name)
      end

      def customer_exists?
        service[:customers].keys.include?(customer_name.to_sym)
      end

      def update_costumer_if_exist
        if customer_exists?
          reset_quantity
          update_last_changed_data(service, customer_name, user)
          repository.update(service)
        else
          @error = msg_customer_not_found(service_name: service_name,
                                          customer_name: customer_name)
        end
      end

      def reset_quantity
        customer[:quantity] = 0

        @message = I18n.t('lita.handlers.service.reset.success',
                          customer_name: customer_name)
      end
    end
  end
end

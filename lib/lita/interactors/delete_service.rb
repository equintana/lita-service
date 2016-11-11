# frozen_string_literal: true
require 'lita/helpers/messages_helper'

module Lita
  module Interactors
    # Deletes an existing service that matches with the given name
    class DeleteService < BaseInteractor
      include Lita::Helpers::MessagesHelper

      attr_reader :data

      def initialize(handler, data)
        @handler = handler
        @data = data
      end

      def perform
        if service_exists?
          delete_service
          @message = I18n.t('lita.handlers.service.delete.success',
                            service_name: name)
        else
          @error = msg_not_found(service_name: name)
        end
        self
      end

      private

      def name
        @name ||= data[2]
      end

      def service_exists?
        repository.exists?(name)
      end

      def delete_service
        repository.delete(name)
      end
    end
  end
end

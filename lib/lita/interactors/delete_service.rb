# frozen_string_literal: true
module Lita
  module Interactors
    # Deletes an existing service that matches with the given name
    class DeleteService < BaseInteractor
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
          @error = I18n.t('lita.handlers.service.delete.error',
                          service_name: name)
        end
        self
      end

      private

      def name
        @name ||= data[1]
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

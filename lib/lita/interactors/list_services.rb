# frozen_string_literal: true
module Lita
  module Interactors
    # List all services
    class ListServices < BaseInteractor
      attr_reader :data

      def initialize(handler, data)
        @handler = handler
        @data = data
      end

      def perform
        @message = services
        self
      end

      private

      def services
        @service ||= repository.all
      end
    end
  end
end

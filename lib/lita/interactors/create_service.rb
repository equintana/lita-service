module Lita
  module Interactors
    # Create a new service with the given data,
    # validating does not exist any service with the same name
    class CreateService < BaseInteractor
      attr_reader :data

      def initialize(handler, data)
        @handler = handler
        @data = data
      end

      def perform
        if service_exists?
          @error = I18n.t('lita.handlers.service.name_duplicated',
                          service_name: name)
        else
          @message = create_service
        end
        self
      end

      private

      def name
        @name ||= data[1]
      end

      def value
        @value ||= data[2].to_f
      end

      def service_exists?
        repository.exists?(name)
      end

      def create_service
        service = build_service
        repository.add(service)
        service
      end

      def build_service
        {
          name: name,
          value: value,
          state: 'active',
          customers: []
        }
      end
    end
  end
end

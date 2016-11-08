# frozen_string_literal: true
module Lita
  module Helpers
    # Message Helper
    module MessagesHelper
      def msg_duplicated(service_name:)
        I18n.t('lita.handlers.service.errors.duplicated',
               service_name: service_name)
      end

      def msg_not_found(service_name:)
        I18n.t('lita.handlers.service.errors.not_found',
               service_name: service_name)
      end

      def msg_customer_duplicated(service_name:, customer:)
        I18n.t('lita.handlers.service.customer.duplicated',
               service_name: service_name,
               customer_name: customer)
      end
    end
  end
end

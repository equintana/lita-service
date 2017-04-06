# frozen_string_literal: true
module Lita
  module Helpers
    # Set last update data such as:
    # last updated date when the customer info was changed
    # and user who made that change
    module LastUpdateHelper
      def update_last_changed_data(service, customer_name, user)
        service[:customers][customer_name.to_sym][:updated_at] = Time.now
        service[:customers][customer_name.to_sym][:updated_by] = user.name
      end
    end
  end
end

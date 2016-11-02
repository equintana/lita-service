# frozen_string_literal: true
module Lita
  module Handlers
    # Handles all commands of the plugin
    class Service < Handler
      namespace :service

      # Routes
      route(/ping/, :pong)
      route(/create ([\w-]+)( [0-9]*)?/, :create)
      route(/delete ([\w-]+)/, :delete)

      # Callbacks
      def pong(response)
        response.reply 'pong!'
      end

      def create(response)
        interactor = Interactors::CreateService
                     .new(self, response.match_data)
                     .perform

        template = :service_created
        message = { service: interactor.message }
        reply(template, message, response, interactor)
      end

      def delete(response)
        interactor = Interactors::DeleteService
                     .new(self, response.match_data)
                     .perform

        template = :service_deleted
        message = { message: interactor.message }
        reply(template, message, response, interactor)
      end

      def reply(template, message, response, interactor)
        unless interactor.success?
          template = :error
          message = { error: interactor.error }
        end
        response.reply(render_template(template, message))
      end

      Lita.register_handler(self)
    end
  end
end

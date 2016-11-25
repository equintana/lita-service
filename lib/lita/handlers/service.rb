# frozen_string_literal: true
module Lita
  module Handlers
    # Handles all commands relative to the service
    class Service < Handler
      namespace :service

      # Routes
      route(/service ping/, :pong,
            command: true,
            help: { 'service ping' =>
                    'Replys _pong_ if the plugin is running' })

      route(/service list/, :list,
            command: true,
            help: { 'service list' =>
                    'List all services' })

      route(/service create ([\w-]+)( [0-9]*)?/, :create,
            command: true,
            help: { 'service create _<name> <*value>_' =>
                    'Create a new service called _<name>_ with value _<*value>_' })

      route(/service show ([\w-]+)/, :show,
            command: true,
            help: { 'service show _<name>_' =>
                    'Shows information on service called _<name>_' })

      route(/service (delete|remove) ([\w-]+)/, :delete,
            command: true,
            help: { 'service delete|remove _<name>_' =>
                    'Deletes a service called _<name>_' })

      # Callbacks
      def pong(response)
        response.reply 'pong!'
      end

      def list(response)
        interactor = Interactors::ListServices.new(self, response.match_data).perform
        template = :list_services
        message = { services: interactor.message }
        reply(template, message, response, interactor)
      end

      def create(response)
        interactor = Interactors::CreateService.new(self, response.match_data).perform
        template = :service_created
        message = { service: interactor.message }
        reply(template, message, response, interactor)
      end

      def show(response)
        interactor = Interactors::ShowService.new(self, response.match_data).perform
        template = :service_show
        message = { service: interactor.message }
        reply(template, message, response, interactor)
      end

      def delete(response)
        interactor = Interactors::DeleteService.new(self, response.match_data).perform
        template = :message
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

# frozen_string_literal: true
module Lita
  module Handlers
    # Handles all commands of the plugin
    class Service < Handler
      namespace :service

      # Routes
      route(/service ping/, :pong, command: true)
      route(/service list/, :list, command: true)
      route(/service create ([\w-]+)( [0-9]*)?/, :create, command: true)
      route(/service show ([\w-]+)/, :show, command: true)
      route(/service (delete|remove) ([\w-]+)/, :delete, command: true)
      route(/service ([\w-]+) inscribe ([\@\w-]+)( [0-9]*)?/, :inscribe, command: true)
      route(/service ([\w-]+) (add|sum) ((?!(?:all))[\@\w-]+)( [0-9-]*)?/, :add,
            command: true)
      route(/service ([\w-]+) (add|sum) all( [0-9-]*)?$/, :add_all,
            command: true)
      route(/service ([\w-]+) (delete|remove) ([\@\w-]+)/, :delete_customer,
            command: true)

      # Callbacks
      def pong(response)
        response.reply 'pong!'
      end

      def list(response)
        interactor = Interactors::ListServices
                     .new(self, response.match_data)
                     .perform

        template = :list_services
        message = { services: interactor.message }
        reply(template, message, response, interactor)
      end

      def create(response)
        interactor = Interactors::CreateService
                     .new(self, response.match_data)
                     .perform

        template = :service_created
        message = { service: interactor.message }
        reply(template, message, response, interactor)
      end

      def show(response)
        interactor = Interactors::ShowService
                     .new(self, response.match_data)
                     .perform

        template = :service_show
        message = { service: interactor.message }
        reply(template, message, response, interactor)
      end

      def delete(response)
        interactor = Interactors::DeleteService
                     .new(self, response.match_data)
                     .perform

        template = :message
        message = { message: interactor.message }
        reply(template, message, response, interactor)
      end

      def inscribe(response)
        interactor = Interactors::InscribeCustomer
                     .new(self, response.match_data)
                     .perform

        template = :message
        message = { message: interactor.message }
        reply(template, message, response, interactor)
      end

      def add(response)
        interactor = Interactors::AddQuantity
                     .new(self, response.match_data)
                     .perform

        template = :message
        message = { message: interactor.message }
        reply(template, message, response, interactor)
      end

      def add_all(response)
        interactor = Interactors::AddAll
                     .new(self, response.match_data)
                     .perform

        template = :message
        message = { message: interactor.message }
        reply(template, message, response, interactor)
      end

      def delete_customer(response)
        interactor = Interactors::DeleteCustomer
                     .new(self, response.match_data)
                     .perform

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

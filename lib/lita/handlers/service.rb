# frozen_string_literal: true
module Lita
  module Handlers
    # Handles all commands of the plugin
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

      route(/service ([\w-]+) inscribe ([\@\w-]+)( [0-9]*)?/, :inscribe,
            command: true,
            help: { 'service _<name>_ inscribe _<user> <*value>_' =>
                    'Registers to _<user>_ with value _<*value>_ on service _<name>_' })

      route(/service ([\w-]+) (add|sum) ((?!(?:all))[\@\w-]+)( [0-9-]*)?/, :add,
            command: true,
            help: { 'service _<name>_ add|sum  _<user> <*quantity>_' =>
                    'Adds _<*quantity>_ or 1 to a _<user>_ ' })

      route(/service ([\w-]+) (add|sum) all( [0-9-]*)?$/, :add_all,
            command: true,
            help: { 'service _<name>_ add|sum all _<*quantity>_' =>
                    'Adds _<*quantity>_ or 1 to all users on service' })

      route(/service ([\w-]+) (delete|remove) ([\@\w-]+)/, :delete_customer,
            command: true,
            help: { 'service _<name>_ delete|remove _<user>_' =>
                    'Deletes a _<user>_ from a service called _<name>_' })

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

      def inscribe(response)
        interactor = Interactors::InscribeCustomer.new(self, response.match_data).perform
        template = :message
        message = { message: interactor.message }
        reply(template, message, response, interactor)
      end

      def add(response)
        interactor = Interactors::AddQuantity.new(self, response.match_data).perform
        template = :message
        message = { message: interactor.message }
        reply(template, message, response, interactor)
      end

      def add_all(response)
        interactor = Interactors::AddAll.new(self, response.match_data).perform
        template = :message
        message = { message: interactor.message }
        reply(template, message, response, interactor)
      end

      def delete_customer(response)
        interactor = Interactors::DeleteCustomer.new(self, response.match_data).perform
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

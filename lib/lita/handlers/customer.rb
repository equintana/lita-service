# frozen_string_literal: true
module Lita
  module Handlers
    # Handles all commands related to the customer
    class Customer < Handler
      namespace :service

      def self.template_root
        File.expand_path('../../../templates', __dir__)
      end

      # Routes
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

      route(/service ([\w-]+) value ([\@\w-]+) ([0-9-]*)$/, :change_value,
            command: true,
            help: { 'service _<name>_ value _<user> <value>_' =>
                    'Sets the value _<value>_ to the _<user>_ on service' })

      route(/service ([\w-]+) (delete|remove) ([\@\w-]+)/, :delete_customer,
            command: true,
            help: { 'service _<name>_ delete|remove _<user>_' =>
                    'Deletes a _<user>_ from a service called _<name>_' })

      # Callbacks
      def inscribe(response)
        interactor = Interactors::InscribeCustomer.new(self, response.match_data).perform
        template = :message
        message = { message: interactor.message }
        reply(template, message, response, interactor)
      end

      def change_value(response)
        interactor = Interactors::ChangeValue.new(self, response.match_data).perform
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

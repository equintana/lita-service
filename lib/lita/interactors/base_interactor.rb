require 'lita/repositories/redis'

module Lita
  module Interactors
    # Base interactors behaviour
    class BaseInteractor
      attr_reader :handler, :message, :error

      def success?
        error.nil?
      end

      def repository
        Repositories::Redis.new(handler.redis)
      end
    end
  end
end

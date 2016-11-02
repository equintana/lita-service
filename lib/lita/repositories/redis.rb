# frozen_string_literal: true
module Lita
  module Repositories
    # Redis repository
    class Redis
      attr_reader :redis

      def initialize(redis)
        @redis = redis
      end

      def exists?(key)
        redis.exists(key)
      end

      def add(resource)
        redis.set(resource[:name], MultiJson.dump(resource))
      end

      def delete(key)
        redis.del(key)
      end
    end
  end
end

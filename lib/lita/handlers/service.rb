module Lita
  module Handlers
    class Service < Handler

      namespace :service

      # Routes


      route(/ping/) { |response| response.reply "pong!" }

      Lita.register_handler(self)
    end
  end
end

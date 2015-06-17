require 'celluloid/current'
require 'celluloid/io'

module Celluloid
  module SMTP
    DEBUG = true
    Logger = Celluloid::Internals::Logger
    class Server
      DEFAULT_HOST = '0.0.0.0'
      DEFAULT_PORT = 2525
      DEFAULT_BACKLOG = 100
      require 'celluloid/smtp/server'
    end
    require 'celluloid/smtp/errors'
    class Connection
      require 'celluloid/smtp/connection'
      require 'celluloid/smtp/connection/automata'
      require 'celluloid/smtp/connection/events'
    end
    module Message
      require 'celluloid/smtp/message/parser'
      require 'celluloid/smtp/message/transporter'
    end
  end
end

require 'celluloid/current'
require 'celluloid/io'
require 'celluloid/smtp/constants'
require 'celluloid/smtp/version'

module Celluloid
  module SMTP
    require 'celluloid/smtp/errors'
    require 'celluloid/smtp/events'
    class Server
      include SMTP::Events
      include SMTP::Constants
      extend Forwardable
      def_delegators :Logger, :debug, :info, :warn, :error
      require 'celluloid/smtp/server'
    end
    class Connection
      include SMTP::Events
      include SMTP::Constants
      extend Forwardable
      def_delegators :Logger, :debug, :info, :warn, :error
      require 'celluloid/smtp/connection'
      require 'celluloid/smtp/connection/automata'
    end
    module Message
      require 'celluloid/smtp/message/parser'
      require 'celluloid/smtp/message/transporter'
    end
  end
end

require 'celluloid/current'
require 'celluloid/io'

module Celluloid
  module SMTP
    require 'celluloid/smtp/constants'
    require 'celluloid/smtp/logging'
    require 'celluloid/smtp/version'
    require 'celluloid/smtp/extensions'
    class Server
      include SMTP::Extensions
      require 'celluloid/smtp/server'
      require 'celluloid/smtp/server/protector'
      require 'celluloid/smtp/server/handler'
      require 'celluloid/smtp/server/transporter'
    end
    class Connection
      include SMTP::Extensions
      require 'celluloid/smtp/connection/errors'
      require 'celluloid/smtp/connection/events'
      require 'celluloid/smtp/connection/parser'
      require 'celluloid/smtp/connection/automata'
      require 'celluloid/smtp/connection'
    end
  end
end

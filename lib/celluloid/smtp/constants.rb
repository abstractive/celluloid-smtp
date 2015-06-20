module Celluloid::SMTP::Constants
  DEBUG = true
  DEBUG_TIMING = true
  DEBUG_AUTOMATA = true

  HANDLERS = 0
  LOGGER = Celluloid::Internals::Logger
  DEFAULT_HOST = '127.0.0.1'
  DEFAULT_PORT = 2525
  DEFAULT_BACKLOG = 100
  DEFAULT_BEHAVIOR = :blackhole
  DEFAULT_HOSTNAME = "localhost"
  TIMEOUT = 9
end

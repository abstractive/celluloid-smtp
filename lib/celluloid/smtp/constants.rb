module Celluloid::SMTP::Constants
  DEBUG = false
  DEBUG_TIMING = true
  DEBUG_AUTOMATA = false
  DEBUG_EVENTS = true

  HANDLERS = 0
  LOGGER = Celluloid::Internals::Logger
  DEFAULT_HOST = '127.0.0.1'
  DEFAULT_PORT = 2525
  DEFAULT_BACKLOG = 100
  DEFAULT_BEHAVIOR = :blackhole
  DEFAULT_HOSTNAME = "localhost"
  TIMEOUT = 9
end

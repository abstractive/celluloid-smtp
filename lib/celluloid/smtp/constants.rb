module Celluloid::SMTP::Constants
  DEBUG = true
  Logger = Celluloid::Internals::Logger
  DEFAULT_HOST = '0.0.0.0'
  DEFAULT_PORT = 2525
  DEFAULT_BACKLOG = 100
  DEFAULT_BEHAVIOR = :blackhole
end

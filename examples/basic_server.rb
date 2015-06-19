$LOAD_PATH.push(File.expand_path("../../lib", __FILE__))

require 'bundler/setup'
require 'celluloid/smtp'

at_exit {
  Celluloid::Internals::Logger.info "Shutting down SMTP server."
  Celluloid[:smtpd].async.shutdown
  sleep 0.126 * 2
  Celluloid.shutdown
}

begin
  Celluloid::SMTP::Server.run
rescue Interrupt
  exit
end

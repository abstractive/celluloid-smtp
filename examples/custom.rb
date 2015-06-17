$LOAD_PATH.push(File.expand_path("../../lib", __FILE__))

require 'bundler/setup'
require 'celluloid/smtp'

Celluloid::SMTP::Logger = Celluloid[:logger] #de Use your own logging actor.


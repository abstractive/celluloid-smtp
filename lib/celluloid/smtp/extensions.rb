module Celluloid::SMTP::Extensions
  def self.included(object)
    object.send(:include, Celluloid::SMTP::Constants)
    object.extend Forwardable
    object.def_delegators :"Celluloid::SMTP::Server.logger", :debug, :console, :warn, :error, :exception
  end
end

class Celluloid::SMTP::Logging
  include Celluloid

  [:debug, :info, :warn, :error].each { |method|
    define_method(method) { |*args| async.log(method,*args) }
  }

  def log(method, *args)
    Celluloid::SMTP::Constants::LOGGER.send(method,*args)
  end
end

Celluloid::SMTP::Logging.supervise as: :logger

module Celluloid::SMTP::Constants
  Logger = Celluloid[:logger]
end

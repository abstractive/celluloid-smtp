class Celluloid::SMTP::Connection::Automata
  include Celluloid::SMTP::Constants
  include Celluloid::FSM

  extend Forwardable
  def_delegators :Logger, :debug, :info, :warn, :error

  def initialize(connection)
    @connection = connection
  end

  default_state :connected

  state :connected, :to => [:parsing, :closed]

  state :parsing, :to => [:parsed, :closed] do
    @connection.parse!
  end

  state :parsed, :to => [:relaying, :delivering, :disconnecting, :closed] do
    @connection.on_message
    if @connection.relaying?
      transition :relaying
    elsif @connection.delivering?
      transition :delivering
    else
      transition :disconnecting
    end
  end

  state :relaying, to: [:relayed, :closed] do

  end

  state :relayed, to: [:disconnecting, :closed] do

  end

  state :delivering, to: [:delivered, :closed] do

  end

  state :delivered, to: [:disconnecting, :closed] do

  end

  state :disconnecting, to: [:closed] do
    debug "Gracefully finishing up connection to #{@connection.remote_ip}"
    transition :closed
  end

  state :closed, :to => [] do
    debug "Closing connection to #{@connection.remote_ip}"
    @connection.close
  end
end

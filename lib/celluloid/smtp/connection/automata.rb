class Celluloid::SMTP::Connection::Automata
  include Celluloid::FSM
  include Celluloid::SMTP::Extensions
  def_delegators :@connection,
                 :delivering?,
                 :relaying?,
                 :closed?,
                 :start!,
                 :finish!,
                 :print,
                 :length,
                 :event!,
                 :handle!

  def initialize(connection)
    @connection = connection
  end

  default_state :initialize

  state :connection, :to => [:handling, :closed] do
    start!
    event!(:on_connection)
    transition :handling
  end

  state :handling, :to => [:handled, :disconnecting, :closed] do
    debug "Parsing message." if DEBUG_AUTOMATA
    handle!
  end

  state :handled, :to => [:relaying, :delivering, :disconnecting, :closed] do
    debug "Finished handling." if DEBUG_AUTOMATA
    if relaying?
      transition :relaying
    elsif delivering?
      transition :delivering
    else
      transition :disconnecting
    end
  end

  state :relaying, to: [:relayed, :closed] do
    debug "Relaying message." if DEBUG_AUTOMATA
  end

  state :relayed, to: [:disconnecting, :closed] do
    debug "Message relayed." if DEBUG_AUTOMATA
  end

  state :delivering, to: [:delivered, :closed] do
    debug "Delivering message."  if DEBUG_AUTOMATA

  end

  state :delivered, to: [:disconnecting, :closed] do
    debug "Message delivered."  if DEBUG_AUTOMATA
  end

  state :disconnecting, to: [:closed] do
    event!(:on_disconnect)
    transition :closed
  end

  state :closed, :to => [] do
    close unless closed? rescue nil
    finish!
    event!(:on_close)
    debug "TIMER: #{"%0.4f" % length} on connection." if DEBUG_TIMING
  end
end

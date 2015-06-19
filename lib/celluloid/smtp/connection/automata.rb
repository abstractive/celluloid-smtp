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
                 :on_connection,
                 :on_disconnect,
                 :on_message,
                 :handle!

  def initialize(connection)
    @connection = connection
  end

  default_state :initialize

  state :connection, :to => [:handling, :closed] do
    start!
    on_connection
    transition :handling
  end

  state :handling, :to => [:handled, :disconnecting, :closed] do
    debug "Parsing message."
    handle!
  end

  state :handled, :to => [:relaying, :delivering, :disconnecting, :closed] do
    debug "Finished handling."
    if relaying?
      transition :relaying
    elsif delivering?
      transition :delivering
    else
      transition :disconnecting
    end
  end

  state :relaying, to: [:relayed, :closed] do
    debug "Relaying message."
  end

  state :relayed, to: [:disconnecting, :closed] do
    debug "Message relayed."
  end

  state :delivering, to: [:delivered, :closed] do
    debug "Delivering message."

  end

  state :delivered, to: [:disconnecting, :closed] do
    debug "Message delivered."
  end

  state :disconnecting, to: [:closed] do
    on_disconnect
    transition :closed
  end

  state :closed, :to => [] do
    close unless closed? rescue nil
    finish!
    debug "Connection time: #{"%0.4f" % (length)}"
  end
end

class Celluloid::SMTP::Connection::Automata
  include Celluloid::FSM

  def initialize(connection)
    @connection = connection
  end

  default_state :connected

  state :connected, :to => [:parsing, :closed]

  state :parsing, :to => [:parsed, :closed] do
    @connection.parse!
  end

  state :parsed, :to => [:relaying, :closed] do
    @connection.on_message
  end

  state :relaying, to: [:relayed, :closed] do
  end

  state :closed, :to => [] do
    @connection.close
  end
end

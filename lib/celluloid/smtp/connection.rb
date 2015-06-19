class Celluloid::SMTP::Connection

  attr_reader :socket, :automata

  extend Forwardable
  def_delegators :@socket, :close, :peeraddr, :print, :closed?
  def_delegators :@automata, :transition

  def initialize(socket, configuration)
    @automata = Automata.new(self)
    @configuration = configuration.dup
    @socket = socket
    @timestamps = {}
    @context = nil
    @behavior = configuration.fetch(:behavior, DEFAULT_BEHAVIOR)
    transition :connection
  end

  def start!
    @timestamps[:start] = Time.now
  end

  def finish!
    @timestamps[:finish] = Time.now
  end

  def length
    raise "Connection incomplete." unless @timestamps[:start] && @timestamps[:finish]
    @timestamps[:finish].to_f - @timestamps[:start].to_f
  end

  def relaying?
    @behavior == :relay
  end

  def delivering?
    @behavior == :deliver
  end

  def print!(string)
    print "#{string}\r\n"
  end

  def remote_ip
    peeraddr(false)[3]
  end
  alias remote_addr remote_ip

  def remote_host
    # NOTE: This is currently a blocking operation.
    peeraddr(true)[2]
  end

end

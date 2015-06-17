class Celluloid::SMTP::Connection

  attr_reader :socket, :automata, :message
  extend Forwardable
  def_delegators :@socket, :close, :peeraddr

  def initialize(socket, configuration)
    @socket = socket
    @behavior = configuration.fetch(:behavior, DEFAULT_BEHAVIOR)
    @configuration = configuration
    @automata = Automata.new(self)
    debug("Connection from #{remote_ip}")
    @automata.transition :parsing
  end

  def relaying?
    @behavior == :relay
  end

  def delivering?
    @behavior == :deliver
  end

  def parse!
    @message = Celluloid::SMTP::Message::Parser.new(self)
    @automata.transition :parsed
  rescue => ex
    error "Error parsing message: #{ex.class}: #{ex.to_s}"
    ex.backtrace.each { |line| error line }
    @automata.transition :closed
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

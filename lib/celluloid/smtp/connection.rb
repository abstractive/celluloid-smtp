class Celluloid::SMTP::Server
  class Connection

    include Events

    attr_reader :socket, :automata, :message

    def initialize(socket)
      @socket = socket
      @automata = Automata.new(self)
      Logger.debug("Connection from #{remote_ip}")
      @automata.transition :parsing
    end

    def parse!
      @message = Message::Parser.new(self)
      @automata.transition :parsed
    rescue => ex
      Logger.error "Error parsing message: #{ex.class}: #{ex.to_s}"
      @automata.transition :closed
    end

    def remote_ip
      @socket.peeraddr(false)[3]
    end
    alias remote_addr remote_ip

    def remote_host
      # NOTE: This is currently a blocking operation.
      @socket.peeraddr(true)[2]
    end

  end
end

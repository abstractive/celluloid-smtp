module Celluloid
  module SMTP
    class Server

      include Celluloid::IO

      def initialize(options={}, &handler)
        @options = options
        @host = options.fetch(:host, DEFAULT_HOST)
        @port = options.fetch(:port, DEFAULT_PORT)
        @server = Celluloid::IO::TCPServer.new(@host, @port)
        @server.listen(options.fetch(:backlog, DEFAULT_BACKLOG))
        @handler = (block_given?) ? handler : &method(:on_connection)
        Logger.info("SMTP Server [ #{@host}:#{@port} ]")
        @options[:rescue] ||= []
        @options[:rescue] += [
          Errno::ECONNRESET,
          Errno::EPIPE,
          Errno::EINPROGRESS,
          Errno::ETIMEDOUT,
          Errno::EHOSTUNREACH
        ]
      end

      def run!(&block)
        async.start(&block)
      end

      def start(&block)
        Logger.info "Starting to handle SMTP connections."
        @online = true
        loop {
          break unless @online
          begin
            socket = @server.accept
            Logger.debug "New connection socket."
          rescue *@options[:rescue] => ex
            Logger.warn "Error accepting socket: #{ex.class}: #{ex.to_s}"
            next
          end
          async.handle_connection(socket)
        }
      end

      def handle_connection(socket)
        connection = Connection.new(socket)
        @handler.call(connection)
      rescue EOFError
        Logger.warn "Premature disconnect."
      end

      def shutdown
        @online = false
        sleep 0.126
        @server.close if @server rescue nil
      end

    end
  end
end

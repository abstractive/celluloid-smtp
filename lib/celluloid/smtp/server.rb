module Celluloid
  module SMTP
    class Server
      include Celluloid::IO
      include Events

      class << self
        def launch(options, &handler)
          supervise(as: :smtpd, args:[options, handler])
        end
        def run!(options={}, &handler)
          launch(options, &handler)
          Celluloid[:smtpd].run!
        end
        def run(options={}, &handler)
          launch(options, &handler)
          Celluloid[:smtpd].run
        end
      end


      def initialize(options={}, handler=nil)
        @options = options
        @host = options.fetch(:host, DEFAULT_HOST)
        @port = options.fetch(:port, DEFAULT_PORT)
        @behavior = options.fetch(:behavior, DEFAULT_BEHAVIOR)
        @handler = handler || method(:on_connection)

        @server = Celluloid::IO::TCPServer.new(@host, @port)
        @server.listen(options.fetch(:backlog, DEFAULT_BACKLOG))

        Logger.info("SMTP Server #{SMTP::VERSION} [ #{@host}:#{@port} ]")

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
        async.run(&block)
      end

      def run(&block)
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
          rescue IOError, EOFError

          end
          async.handle_connection(socket)
        }
      end

      def handle_connection(socket)
        connection = Connection.new(socket, @options)
        @handler.call(connection)
      rescue EOFError, IOError
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

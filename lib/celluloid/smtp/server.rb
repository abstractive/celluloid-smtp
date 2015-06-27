module Celluloid
  module SMTP
    class Server
      include Celluloid::IO
      class << self
        @logger = nil
        attr_accessor :logger
        def launch(options)
          unless @logger
            Celluloid::SMTP::Logging.supervise as: :logger
            @logger = Celluloid[:logger]
          end
          if SMTP::Constants::HANDLERS > 0
            Celluloid::SMTP::Server::Handler.supervise as: :handler, size: SMTP::Constants::HANDLERS
          end
          supervise(as: :smtpd, args:[options])
          Celluloid[:smtpd]
        end
        def run!(options={})
          launch(options)
        end
        def run(options={})
          launch(options)
          sleep
        end
      end

      finalizer :ceased

      def ceased
        @server.close rescue nil
        warn "SMTP Server offline."
      end

      def initialize(options={})
        @options = options
        @host = options.fetch(:host, DEFAULT_HOST)
        @port = options.fetch(:port, DEFAULT_PORT)
        @behavior = options.fetch(:behavior, DEFAULT_BEHAVIOR)
        @hostname = options.fetch(:hostname, DEFAULT_HOSTNAME)
        @backlog = options.fetch(:backlog, DEFAULT_BACKLOG)

        @server = Celluloid::IO::TCPServer.new(@host, @port)
        @server.listen(options.fetch(:backlog, @backlog))

        console("Celluloid::IO SMTP Server #{SMTP::VERSION} @ #{@host}:#{@port}")

        @options[:rescue] ||= []
        @options[:rescue] += [
          Errno::ECONNRESET,
          Errno::EPIPE,
          Errno::EINPROGRESS,
          Errno::ETIMEDOUT,
          Errno::EHOSTUNREACH
        ]
        async.run
      end

      def shutdown
        @online = false
        sleep 0.126
        @server.close if @server rescue nil
      end

      private

      def run
        console "Starting to handle SMTP connections, with #{HANDLERS} handlers."
        @online = true
        loop {
          break unless @online
          begin
            socket = @server.accept
            async.connection(socket)
          rescue IOError, EOFError, *@options[:rescue] => ex
            exception(ex, "Socket Error")
            socket.close rescue nil
            next
          end
        }
      end

      def connection(socket)
        if HANDLERS > 0
          Celluloid[:handler].socket(socket, @options)
        else
          self.class.protector(socket) { |io| Connection.new(io, @options) }
        end
      end

    end
  end
end

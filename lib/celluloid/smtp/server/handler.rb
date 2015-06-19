class Celluloid::SMTP::Server::Handler
  include Celluloid
  def socket(socket, options)
    async.serve(socket,options)
  end
  def serve(socket, options)
    SMTP::Server.protector(socket) { |io|
      SMTP::Connection.new(io,options)
    }
  end
end

class Celluloid::SMTP::Server
  class << self
    include Celluloid::SMTP::Extensions
    def protector(io)
      Thread.new {
        Timeout.timeout(TIMEOUT) {
          yield(io)
        }
      }.value
    rescue EOFError, IOError
      warn "Premature disconnect."
    rescue Timeout::Error
      warn "Timeout handling connection."
    rescue Exception => ex
      exception(ex, "Unknown connection error")
    ensure
      io.close
    end     
  end
end

$LOAD_PATH.push(File.expand_path("../../lib", __FILE__))

require 'bundler/setup'
require 'mail'

INTERVAL = 2.22

Mail.defaults do
  delivery_method :smtp, address: "localhost", port: 2525
end

TO = "smtp@celluloid.io"
FROM = TO

fail "No TO address specified." unless TO

puts "Simulating sending a message every #{INTERVAL} seconds."

futures = []
@mutex = Mutex.new
begin
  Thread.new {
    @mutex.synchronize {
      loop {
        futures = Thread.new {
          start = Time.now
          mail = Mail.new do
            from      FROM
            to        TO
            subject   'Test email.'
            body      "Test message.... #{start}"
          end

          begin
            mail.deliver
            print "|"
          rescue Errno::ECONNREFUSED
            print "X"
          rescue EOFError
            print "?"
          rescue => ex
            print "!"
            STDERR.puts "Error communicating with server: #{ex} (#{ex.class})"
          end
        }  
        sleep INTERVAL
      }
    }
  }

  loop {
    future = @mutex.synchronize { futures.shift }.value rescue nil
  }
rescue Interrupt
  puts "Done testing."
end

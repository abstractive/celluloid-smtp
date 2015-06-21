$LOAD_PATH.push(File.expand_path("../../lib", __FILE__))

require 'bundler/setup'
require 'mail'

INTERVAL = (ARGV[0] || 2.22).to_f
HOST = ARGV[1] || "localhost"
PORT = (ARGV[2] || 2525).to_i
TO = ARGV[3] || "smtp@celluloid.io"
FROM = ARGV[4] || TO

Mail.defaults do
  delivery_method :smtp, address: HOST, port: PORT
end

TO = ARGV[2] || "smtp@celluloid.io"
FROM = ARGV[3] || TO

fail "No TO address specified." unless TO

puts "Simulating sending a message every #{INTERVAL} seconds."

futures = []
@mutex = Mutex.new
begin
  Thread.new {
    @mutex.synchronize {
      loop {
        futures = Thread.new {
          begin
            start = Time.now
            mail = Mail.new do
              from      FROM
              to        TO
              subject   "Test email: test_messages.rb @ #{Time.now.to_i}"
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
          rescue => ex
            puts "Error: #{ex} (#{ex.class})"
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

puts "Finished."

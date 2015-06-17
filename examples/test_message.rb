$LOAD_PATH.push(File.expand_path("../../lib", __FILE__))

require 'bundler/setup'
require 'mail'

Mail.defaults do
  delivery_method :smtp, address: "localhost", port: 2525
end

fail "No TO address specified." unless ARGV[0]

puts "Simulating sending a message every 5 seconds, to #{ARGV[0]}."

begin
  loop {
    mail = Mail.new do
      from      'smtp@celluloid.io'
      to        ARGV[0]
      subject   'Test email.'
      body      "Test message.... #{Time.now}"
    end

    begin
      mail.deliver
    rescue => ex
      puts "Error communicating with server: #{ex} (#{ex.class})"
    end
    sleep 5
  }
rescue Interrupt
  puts "Done testing."
end

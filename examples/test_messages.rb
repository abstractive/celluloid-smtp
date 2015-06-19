$LOAD_PATH.push(File.expand_path("../../lib", __FILE__))

require 'bundler/setup'
require 'mail'

Mail.defaults do
  delivery_method :smtp, address: "localhost", port: 2525
end

TO = "test@extremist.digital"
FROM = TO

fail "No TO address specified." unless TO

puts "Simulating sending a message every 5 seconds, to #{TO}."

begin
  loop {
    mail = Mail.new do
      from      FROM
      to        TO
      subject   'Test email.'
      body      "Test message.... #{Time.now}"
    end

    begin
      mail.deliver
      puts "Sent message."
    rescue => ex
      puts "Error communicating with server: #{ex} (#{ex.class})"
    end
    sleep 5
  }
rescue Interrupt
  puts "Done testing."
end

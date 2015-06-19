$LOAD_PATH.push(File.expand_path("../../lib", __FILE__))

require 'bundler/setup'
require 'celluloid/current'
require 'mail'

TESTS = 1000
THREADS = 4

TO = "test@extremist.digital"
FROM = TO

Mail.defaults do
  delivery_method :smtp, address: "localhost", port: 2525
end

fail "No TO address specified." unless TO

puts "Simulating sending #{TESTS}x#{THREADS} messages to #{TO}."

class Sender
  include Celluloid
  def tests(count)
    times = count.times.map { future.test }
    values = times.map(&:value)
    failures = values.select { |v| v == :fail }.count
    values.select! { |v| v != :fail }
    average = values.inject{ |sum, t| sum + t }.to_f / values.size
    return [0, failures] if failures == count
    [average,failures]
  end
  def test
    start = Time.now
    mail = Mail.new do
      from      FROM
      to        TO
      subject   'Test email.'
      body      "Test message.... #{Time.now}"
    end

    begin
      mail.deliver
      print "."
      return Time.now.to_f - start.to_f
    rescue => ex
      print "!"
      :fail
    end
  end
end

senders = THREADS.times.map { Sender.new }

start = Time.now

tests = senders.map {|sender|
  sender.future.tests(TESTS)
}

values = tests.map(&:value)
total=Time.now-start

failures = values.map { |v| v[1] }.inject{ |sum,f| sum + f }
times = values.map { |v| v[0] }
average = times.inject{ |sum, t| sum + t }.to_f / values.size

puts ""
if failures == THREADS*TESTS
  puts "All #{THREADS*TESTS} messages failed."
else
  puts "Average time for #{TESTS}x#{THREADS} messages: #{"%0.4f" % average} seconds per message, with #{failures} failures."
end

puts "Total time running test: #{"%0.4f" % total} ( ~#{"%0.4f" % (total/(TESTS*THREADS))} per message )"

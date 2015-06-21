$LOAD_PATH.push(File.expand_path("../../lib", __FILE__))

require 'bundler/setup'
require 'celluloid/current'
require 'mail'

TESTS = 1000
THREADS = 4

HOST = ARGV[0] || "localhost"
PORT = (ARGV[1] || 2525).to_i
TO = ARGV[2] || "smtp@celluloid.io"
FROM = ARGV[3] || TO

Mail.defaults do
  delivery_method :smtp, address: HOST, port: PORT
end

fail "No TO address specified." unless TO

puts "Simulating sending #{TESTS}x#{THREADS} messages through #{HOST}@#{PORT}."

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
      STDERR.puts "Error communicating with server: #{ex} (#{ex.class})"
      STDERR.puts ex.backtrace
      print "!"
      :fail
    end
  end
end

senders = THREADS.times.map { Sender.new }

start = Time.now
tests = senders.map {|sender| sender.future.tests(TESTS) }

values = tests.map(&:value)
total = Time.now-start
total_fail = false

puts "\n\n\n* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *"
failures = values.map { |v| v[1] }.inject{ |sum,f| sum + f }
average = values.map { |v| v[0] }.inject{ |sum, t| sum + t }.to_f / values.size
overall_average = total/(TESTS*THREADS)
if total_fail
  puts "\n    All #{THREADS*TESTS} messages failed."
  total_fail = true
end
puts "\n    Failures: #{failures}"
puts "\n    Average time for #{TESTS}x#{THREADS} messages:"
puts "      ~#{"%0.4f" % average} seconds per message, actual estimate." unless total_fail
puts "      ~#{"%0.4f" % (overall_average)} of overall runtime, per message."
puts "\n    Total time running test: #{"%0.4f" % total} seconds:"
puts "      ~#{"%0.4f" % (1/average)} messages per second, actual estimate." unless total_fail
puts "      ~#{"%0.4f" % (1/overall_average)} messages per second, overall."
puts "\n* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *\n\n\n"

#!/usr/bin/env ruby

require 'socket'
require 'thread'
require 'time'
require 'json'

HOST_INDEX=0
PORT_INDEX=1
CLIENT_INDEX=2
INTERVAL_INDEX=3
SEND_INDEX=4

# Server details
server_host = ARGV[HOST_INDEX] || 'localhost'
server_port = ARGV[PORT_INDEX] || 20001

# Number of parallel clients
client_count = ARGV[CLIENT_INDEX] || 500

interval = ARGV[INTERVAL_INDEX] || 5

send_count = ARGV[SEND_INDEX] || 60


# Message to send to the server
metric = { timestamp: (Time.now.utc.to_f * 1000).to_i,
                    metric_family: "test",
                    metric_name: "test",
                    metric_value: 1,
                    tags_resource_id: 'fee443fe-4645-40c8-9c41-922a7ab29021',
                    tags_resource_name: 'test resource name',
                    tags_account_id: 'bb6eb76a-4767-48bb-b85b-067fcfbb665b',
                    tags_account_name: 'test account name',
                    tags_host: 'any' }

metric_message = metric.to_json

clients = []
client_count.times do |client_i|
  clients << Thread.new do
    send_count.times do |send_i|
      socket ||= TCPSocket.new(server_host, server_port)
      socket.puts(metric_message)

      sleep (interval)
    rescue StandardError => e
      puts "error client:#{client_i} send:#{send_i}"
      socket&.close
      socket = nil
      retry
    end
  end
end

# Wait for all threads to complete
clients.each(&:join)

puts "Load test completed."
puts "total: #{client_count * send_count}"

#!/usr/bin/env ruby

require 'resolv'

def resolv4(fqdn)
  ip_address = Resolv.getaddress(fqdn)
  puts "IPv4 Address for #{fqdn}: #{ip_address}"
rescue Resolv::ResolvError => e
  puts "Could not resolve #{fqdn}: #{e}"
end

ARGV.each do |fqdn|
  resolv4(fqdn)
end

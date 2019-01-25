#!/usr/bin/env ruby

puts "Starting up"

TOTAL = 10

TOTAL.times do |n|
  STDOUT.flush
  sleep 1 
  puts "Progress: step #{n+1} of #{TOTAL}"
end

STDOUT.flush
puts "Done"

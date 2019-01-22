#!/usr/bin/env ruby

puts "Starting up"

100.times do |n|
  sleep 3

  puts "Progress: Step #{n} of 100: (#{n}%)"
end

puts "Done"

require './main/fire_in_the_lantern'
include FireInTheLantern

message "Testing : #{neo.class} #{neo.mode.to_s.upcase} #{neo.pixel_count}px"

neo.test (ARGV[0]&.to_i || 1)

message 'Done'

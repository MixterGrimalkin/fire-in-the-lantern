require_relative '../neo_pixel/osc_server'
require_relative 'fire_in_the_lantern'

include FireInTheLantern

message 'Running in Direct OSC mode'
osc.start
message 'Press CTRL + C to exit'

wait_for_interrupt

neo.off

puts
puts 'Done'
puts

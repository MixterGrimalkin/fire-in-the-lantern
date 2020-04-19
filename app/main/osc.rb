require_relative 'fire_in_the_lantern'

include FireInTheLantern

message 'Direct OSC-Control mode'

message osc.to_s
osc.start

message 'Press CTRL + C to exit'
wait_for_interrupt

neo.off

message 'Done'

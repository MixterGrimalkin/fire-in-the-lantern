require_relative '../main/fire_in_the_lantern'

include FireInTheLantern

message 'Direct OSC-Control mode'
message osc.to_s

osc.start

wait_for_interrupt 'Press CTRL + C to exit'

neo.off

message 'Done'

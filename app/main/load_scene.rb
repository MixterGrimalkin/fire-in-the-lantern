require_relative 'fire_in_the_lantern'

include FireInTheLantern

unless (scene_name = ARGV[0])
  message 'Specify a Scene to load'
  exit
end

px.load_scene scene_name
px.start
message 'Press CTRL + C to make it stop'

wait_for_interrupt

px.clear
px.stop
neo.close

message 'Bye'
